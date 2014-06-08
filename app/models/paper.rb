class Paper < ActiveRecord::Base
  belongs_to :user
  has_many :annotations
  has_many :assignments

  has_many :reviewers, -> { where('assignments.role = ?', 'reviewer') }, :through => :assignments, :source => :user
  has_many :editors, -> { where('assignments.role = ?', 'editor') }, :through => :assignments, :source => :user
  has_many :collaborators, -> { where('assignments.role = ?', 'collaborator') }, :through => :assignments, :source => :user

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

  def pretty_submission_date
    submitted_at.strftime("%-d %B %Y")
  end

  def draft?
    state == "pending"
  end

  def self.for_user(user)
    # TODO Return papers for a user in a given role
  end

  def to_param
    sha
  end

  private

  def set_sha
    self.sha = SecureRandom.hex
  end
end
