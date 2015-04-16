class Paper < ActiveRecord::Base
  include AASM

  belongs_to :user
  has_many :annotations
  has_many :assignments

  has_many :reviewers, -> { where('assignments.role = ?', 'reviewer') }, :through => :assignments, :source => :user
  has_many :collaborators, -> { where('assignments.role = ?', 'collaborator') }, :through => :assignments, :source => :user

  # Which User is this currently for the attention of?
  belongs_to :fao, :class_name => "User", :foreign_key => "fao_id"

  scope :active, -> { all }


  before_create :set_iniital_values, :get_arxiv_details


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

  def editors
    User.editors
  end

  def pretty_submission_date
    submitted_at.strftime("%-d %B %Y")
  end

  def draft?
    submitted?
  end

  def self.for_user(user)
    user.papers
  end

  def to_param
    sha
  end

  def assign_reviewer(user)
    # Change this to actually be username later on. Also this is a mess tidy up later

    return true if user.reviewer_of? self

    if assignments.create(user: user, role:"reviewer")
      true
    else
      errors.add(:assignments, 'Unable to assign user')
      false
    end
  end

  def remove_reviewer(user)
    assignments.where(user_id: user.id).where(role: "reviewer").first.destroy
  end

  # FIXME if the UI needs it then we should add "submittor" and "editor" in here.
  def permissions_for_user(user)
    assigned = assignments.where(:user_id => user.id).pluck(:role)
    if user.author_of?(self)
      assigned << "submittor"
    end

    if user.editor?
      assigned << "editor"
    end

    assigned
  end

  private

  def set_iniital_values
    self.sha = SecureRandom.hex
    self.submitted_at = Time.now
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
