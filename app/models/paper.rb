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

  before_create :set_initial_values, :get_arxiv_details
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

  def assign_reviewer(user)
    can_assign = ! user.author_of?(self)  &&
                 ! user.reviewer_of?(self) &&
                 ! user.collaborator_on?(self)

    if can_assign && assignments.create(user: user, role:"reviewer")
      true
    else
      errors.add(:assignments, 'Unable to assign user')
      false
    end
  end

  def remove_reviewer(user)
    assignment = assignments.where(user_id: user.id).where(role: 'reviewer').first

    if assignment
      assignment.destroy
      true

    else
      false
    end
  end

  # FIXME if the UI needs it then we should add "submittor" and "editor" in here.
  def permissions_for_user(user)
    assignments.where(user_id:user.id).pluck(:role)
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

  def get_arxiv_details
    details          = Arxiv.get(self.arxiv_id.to_s)

    location         = details.links.select{|link| link.content_type=="application/pdf"}.first.url
    location         = location + ".pdf" unless location.ends_with? ".pdf"
    self.location    = location

    self.title       = details.title
    self.summary     = details.summary
    self.author_list = details.authors.collect{|a| a.name}.join(", ")

  rescue => ex
    self.location  = "http://arxiv.org/pdf/#{self.arxiv_id}.pdf"
    logger.debug "couldn't find paper on arxiv #{ex}"
  end

  def has_reviewers?
    reviewers.any?
  end

end
