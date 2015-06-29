class Paper < ActiveRecord::Base
  include AASM

  has_many   :annotations, inverse_of: :paper, dependent: :destroy
  has_many   :assignments, inverse_of: :paper, dependent: :destroy do
    def for_user(user, role=nil)
      if role
        where(user:user, role:role).first
      else
        where(user:user).first
      end
    end
  end

  has_one   :submittor_assignment,     -> { where('assignments.role = ?', 'submittor') },    class_name:'Assignment'
  has_many  :collaborator_assignments, -> { where('assignments.role = ?', 'collaborator') }, class_name:'Assignment'
  has_many  :reviewer_assignments,     -> { where('assignments.role = ?', 'reviewer') },     class_name: 'Assignment'
  has_many  :editor_assignments,       -> { where('assignments.role = ?', 'editor') },       class_name:'Assignment'

  belongs_to :submittor,                class_name:'User', inverse_of: :papers_as_submittor
  has_many   :collaborators,            through: :collaborator_assignments, source: :user
  has_many   :reviewers,                through: :reviewer_assignments,     source: :user
  has_many   :editors,                  through: :editor_assignments,       source: :user
  has_many   :assignees,                through: :assignments,              source: :user

  scope :active,     -> { where.not(state:'superceded') }
  scope :with_state, ->(state=nil) { state.present? ?  where(state:state) : all }

  before_create :create_assignments

  # Using after commit since creating revisions happens in a transaction
  after_commit  :send_submittor_emails, on: :create

  validates :submittor_id,
            :provider_type,
            :provider_id,
            :version,
             presence: true

  aasm column: :state do
    state :submitted,          initial:true
    state :under_review
    state :review_completed
    state :superceded
    state :accepted
    state :rejected

    event :start_review, guard: :has_reviewers?, after_commit: :send_state_change_emails do
      transitions from: :submitted,
                  to:   :under_review
    end
    event :complete_review, after_commit: [:send_state_change_emails, :send_review_completed_emails] do
      transitions from: :under_review,
                  to:   :review_completed
    end

    event :supercede do
      transitions from: [:submitted, :under_review],
                  to:   :superceded
    end

    event :accept, before: :resolve_all_issues, after_commit: :send_state_change_emails do
      transitions from: :review_completed,
                  to:   :accepted
    end
    event :reject, after_commit: :send_state_change_emails do
      transitions from: [:under_review, :review_completed],
                  to:   :rejected
    end

  end

  def self.for_identifier(identifier)
    if identifier.is_a?(Integer) || identifier =~ /^\d+$/
      where(id:identifier).first!

    else
      provider_type, provider_id, version = Provider.parse_identifier(identifier)

      relation = where(provider_type:provider_type, provider_id:provider_id)
      relation = version ? relation.where(version:version) : relation.order(version: :desc)
      relation.first!
    end
  end

  def self.versions_for(provider_type, provider_id)
    if provider_id
      where(provider_type:provider_type, provider_id:provider_id).order(version: :desc)
    else
      none
    end
  end

  def create_updated!(attributes)
    original = self

    raise 'Providers do not match'            unless original.provider_type.to_sym == attributes[:provider_type]
    raise 'Provider IDs do not match'         unless original.provider_id          == attributes[:provider_id]
    raise 'Cannot update superceded original' unless original.may_supercede?
    raise 'No new version available'          unless original.version              <  attributes[:version]

    ActiveRecord::Base.transaction do
      attributes = attributes.merge(submittor: original.submittor, state: original.state)
      new_paper = Paper.new(attributes)

      original.assignments.each do |assignment|
        new_paper.assignments << Assignment.build_copy(assignment)
      end

      new_paper.save!

      original.supercede!

      new_paper
    end

  end

  def can_destroy?
    submitted? || superceded?
  end

  def full_provider_id
    provider.full_identifier(self)
  end

  def issues
    annotations.root_annotations
  end

  def outstanding_issues
    issues.where.not(state:'resolved')
  end

  def resolve_all_issues
    issues.each(&:resolve!)
  end

  def to_param
    "#{provider_type}#{Provider::SEPARATOR}#{full_provider_id}"
  end

  # Newest version first
  def all_versions
    @all_versions ||= (provider_id ? Paper.versions_for(provider_type, provider_id) : [self])
  end

  def is_revision?
    all_versions.length>1 && self != all_versions.last
  end

  def is_latest_version?
    # self == all_versions.first
    # A little more efficient
    ! superceded?
  end

  def is_original_version?
    all_versions.empty? || self == all_versions.last
  end

  def add_assignee(user, role='reviewer')
    can_assign = ! assignments.for_user(user)

    if can_assign && a=assignments.create(user: user, role:role)
      true
    else
      errors.add(:assignments, 'Unable to assign user')
      false
    end
  end

  def mark_review_completed!(reviewer)
    errors.add(:base, 'Review cannot be marked as complete') and return unless may_complete_review?
    assignment = assignments.for_user(reviewer, :reviewer)
    errors.add(:base, 'Assignee is not a reviewer') and return unless assignment

    return true if assignment.completed?

    assignment.update_attributes!(completed:true)

    all_reviews_completed = reviewer_assignments.all?(&:completed?)
    complete_review! if all_reviews_completed

    true
  end

  def make_reviewer_public!(reviewer, public=true)
    errors.add(:base, 'Review cannot be marked as complete') and return unless is_latest_version?
    assignment = assignments.for_user(reviewer, :reviewer)
    errors.add(:base, 'Assignee is not a reviewer') and return unless assignment

    all_versions.each do |paper|
      assignment = paper.assignments.for_user(reviewer, :reviewer)
      assignment.update_attributes!(public:public) if assignment
    end

    true
  end

  def permissions_for_user(user)
    assignments.where(user_id:user.id).pluck(:role)
  end

  def firebase_key
    "/papers/#{sha}"
  end

  private

  def provider
    @provider ||= Provider[provider_type]
  end

  def has_reviewers?
    reviewers.any?
  end

  def create_assignments

    if assignments.none? { |a| a.role=='editor' }
      editor = User.next_editor
      assignments.build(role:'editor',   user:editor) if editor
    end

    if assignments.none? { |a| a.role=='submittor' && a.user==submittor }
      assignments.build(role:'submittor',user:submittor)
    end

  end

  def send_submittor_emails

    if is_original_version?
      NotificationMailer.notification(submittor, self,
                                      'You have submitted a new paper.',
                                      'Paper Submitted'
      ).deliver_later

    else
      NotificationMailer.notification(submittor, self,
                                      'You have submitted a new revision of a paper',
                                      'Paper Revised'
      ).deliver_later

    end

  end

  def send_state_change_emails
    state_name = state.titleize

    NotificationMailer.notification(submittor, self,
                                    "The state of your paper has changed to #{state_name}",
                                    "Paper #{state_name}"
    ).deliver_later
  end

  def send_review_completed_emails
    editors.each do |editor|
      NotificationMailer.notification(editor, self,
                                      "Reviews have been completed on a paper you are editing",
                                      "Review Completed"
      ).deliver_later
    end
  end

end
