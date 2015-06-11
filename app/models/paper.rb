class Paper < ActiveRecord::Base
  include AASM

  ArxivIdRegex = /[0-9]{4}.*[0-9]{4,5}/
  ArxivIdWithVersionRegex = /[0-9]{4}.*[0-9]{4,5}(v\d+)?/

  has_many   :annotations, inverse_of: :paper, dependent: :destroy
  has_many   :assignments, inverse_of: :paper, dependent: :destroy

  has_one   :submittor_assignment,     -> { where('assignments.role = ?', 'submittor') },    class_name:'Assignment'
  has_many  :collaborator_assignments, -> { where('assignments.role = ?', 'collaborator') }, class_name:'Assignment'
  has_many  :reviewer_assignments,     -> { where('assignments.role = ?', 'reviewer') },     class_name: 'Assignment'
  has_many  :editor_assignments,       -> { where('assignments.role = ?', 'editor') },       class_name:'Assignment'

  belongs_to :submittor,                class_name:'User', inverse_of: :papers_as_submittor
  has_many  :collaborators,             through: :collaborator_assignments, source: :user
  has_many  :reviewers,                 through: :reviewer_assignments,     source: :user
  has_many  :editors,                   through: :editor_assignments,       source: :user

  scope :active, -> { where.not(state:'superceded') }

  before_create :set_initial_values,
                :create_assignments

  # Using after commit since creating revisions happens in a transaction
  after_commit  :send_submittor_emails, on: :create

  validates :submittor,
            presence: true

  aasm column: :state do
    state :submitted,          initial:true
    state :under_review
    state :superceded
    state :accepted
    state :rejected

    event :start_review, guard: :has_reviewers?, after_commit: :send_state_change_emails do
      transitions from: :submitted,
                  to:   :under_review
    end

    event :supercede do
      transitions from: [:submitted, :under_review],
                  to:   :superceded
    end

    event :accept, before: :resolve_all_issues, after_commit: :send_state_change_emails do
      transitions from: :under_review,
                  to:   :accepted
    end
    event :reject, after_commit: :send_state_change_emails do
      transitions from: :under_review,
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
    where(arxiv_id:arxiv_id).order(version: :desc)
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

      original.assignments.each do |a|
        new_paper.assignments.build(role:a.role, user:a.user, updated:true)
      end

      new_paper.save!

      original.supercede!

      new_paper
    end

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
    @all_versions ||= Paper.versions_for(arxiv_id)
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
    self == all_versions.last
  end

  def user_assignment(user)
    assignments.detect { |a| a.user == user }
  end

  def add_assignee(user, role='reviewer')
    can_assign = ! user_assignment(user)

    if can_assign && a=assignments.create(user: user, role:role)
      true
    else
      errors.add(:assignments, 'Unable to assign user')
      false
    end
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

end
