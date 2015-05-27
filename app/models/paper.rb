class Paper < ActiveRecord::Base
  include AASM

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

  scope :active, -> { all }

  before_create :set_initial_values
  after_create  :create_assignments

  validates :submittor,
            presence: true

  aasm column: :state do
    state :submitted,          initial:true
    state :under_review
    state :accepted
    state :rejected

    event :accept, before: :resolve_all_issues do
      transitions from: :under_review,
                  to:   :accepted
    end
    event :reject do
      transitions from: :under_review,
                  to:   :rejected
    end

    event :start_review, guard: :has_reviewers? do
      transitions from: :submitted,
                  to:   :under_review
    end

  end

  def self.with_state(state = nil)
    if state
      where(state:state)
    else
      all
    end
  end

  def self.new_for_arxiv_id(arxiv_id, attributes={})
    begin
      details = Arxiv.get(arxiv_id.to_s)
    rescue Arxiv::Error::ManuscriptNotFound
      raise ActiveRecord::RecordNotFound
    end

    attributes = attributes.merge(
        arxiv_id:    details.arxiv_id,
        version:     details.version,

        title:       details.title,
        summary:     details.summary,
        location:    details.pdf_url,
        author_list: details.authors.collect{|a| a.name}.join(", ")
    )

    new(attributes)
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

  def pretty_submission_date
    submitted_at.strftime("%-d %B %Y")
  end

  def draft?
    submitted?
  end

  def to_param
    sha
  end

  def user_assignment(user)
    assignments.detect { |a| a.user == user }
  end

  def add_assignee(user, role)
    can_assign = ! user_assignment(user)

    if can_assign && assignments.create(user: user, role:role)
      true
    else
      errors.add(:assignments, 'Unable to assign user')
      false
    end
  end

  # FIXME if the UI needs it then we should add "submittor" and "editor" in here.
  def permissions_for_user(user)
    assignments.where(user_id:user.id).pluck(:role)
  end

  def firebase_key
    "/papers/#{sha}"
  end

  private

  def set_initial_values
    self.sha = SecureRandom.hex
    self.submitted_at = Time.now
  end

  def create_assignments
    editor = User.next_editor
    self.assignments.create(role:'editor',   user:editor) if editor
    self.assignments.create(role:'submittor',user:submittor)
  end

  def has_reviewers?
    reviewers.any?
  end

end
