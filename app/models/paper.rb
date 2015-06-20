class Paper < ActiveRecord::Base
  include AASM

  ArxivIdRegex = /\d{4}\.\d{4,5}/
  ArxivIdWithVersionRegex = /\d{4}\.\d{4,5}(v\d+)?/

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

  scope :active, -> { where.not(state:'superceded') }

  before_create :set_initial_values,
                :create_assignments

  # Using after commit since creating revisions happens in a transaction
  after_commit  :send_submittor_emails, on: :create

  validates :submittor_id,
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

  def self.with_state(state = nil)
    if state
      where(state:state)
    else
      all
    end
  end

  def self.versions_for(arxiv_id)
    if arxiv_id
      where(arxiv_id:arxiv_id).order(version: :desc)
    else
      none
    end
  end

  def self.new_for_arxiv_id(arxiv_id, attributes={})
    arxiv_doc = Arxiv.get(arxiv_id.to_s)
    new_for_arxiv(arxiv_doc, attributes)
  end

  def self.new_for_arxiv(arxiv_doc, attributes={})

    attributes = attributes.merge(
        arxiv_id:    arxiv_doc.arxiv_id,
        version:     arxiv_doc.version,

        title:       arxiv_doc.title,
        summary:     arxiv_doc.summary,
        location:    arxiv_doc.pdf_url,
        author_list: arxiv_doc.authors.collect{|a| a.name}.join(", ")
    )

    new(attributes)
  end

  def self.create_updated!(original, arxiv_doc)

    raise 'Arxiv IDs do not match'            unless original.arxiv_id == arxiv_doc.arxiv_id
    raise 'Cannot update superceded original' unless original.may_supercede?
    raise 'No new version available'          unless arxiv_doc.version > original.version

    ActiveRecord::Base.transaction do
      new_paper = Paper.new_for_arxiv(arxiv_doc,
                                      submittor: original.submittor,
                                      state:     original.state
      )

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

  def full_arxiv_id
    "#{arxiv_id}v#{version}"
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
    sha
  end

  # Newest version first
  def all_versions
    @all_versions ||= (arxiv_id ? Paper.versions_for(arxiv_id) : [self])
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

  def set_initial_values
    self.sha ||= SecureRandom.hex
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
