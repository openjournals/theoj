class Paper < ActiveRecord::Base
  belongs_to :user
  has_many :annotations
  has_many :assignments

  has_many :reviewers, -> { where('assignments.role = ?', 'reviewer') }, :through => :assignments, :source => :user
  has_many :collaborators, -> { where('assignments.role = ?', 'collaborator') }, :through => :assignments, :source => :user

  scope :active, -> { where('state != ?', 'pending') }

  before_create :set_sha

  state_machine :initial => :pending do
    state :submitted
    state :under_review
    state :accepted

    after_transition :on => :accept, :do => :resolve_all_issues

    event :accept do
      transition all => :accepted
    end
    event :assigned do
      transition :submitted => :under_review
    end
  end

  def self.with_state(state = nil)
    if state
      where('state = ?', state)
    else
      all
    end
  end

  # FIXME should be a scope
  def outstanding_issues
    annotations.where('state != ?', 'resolved')
  end

  def resolve_all_issues
    annotations.each(&:resolve)
  end

  def pretty_status
    state.humanize
  end

  def editors
    User.editors
  end

  def pretty_submission_date
    submitted_at.strftime("%-d %B %Y")
  end

  def draft?
    state == "pending"
  end

  def self.for_user(user)
    user.papers
  end

  def to_param
    sha
  end

  def assign_reviewer(user)
    # Change this to actually be username later on. Also this is a mess tidy up later
    assigned = false

    if user.reviewer_of? self
       return true
    end

    if assignments.create(user: user, role:"reviewer")
      assigned = true
    else
      @errors = ["Something bad went wrong"]
    end

    assigned
  end

  def remove_reviewer(user)
    assignments.where(user_id: user.id).where(role: "reviewer").first.destroy
  end

  # FIXME if the UI needs it then we should add "submittor" and "editor" in here.
  def permissions_for_user(user)
    assigned = assignments.where(:user_id => user.id).collect { |assignment| assignment.role }
    if user.author_of?(self)
      assigned << "submittor"
    end

    if user.editor?
      assigned << "editor"
    end

    return assigned
  end

  private

  def set_sha
    self.sha = SecureRandom.hex
  end
end
