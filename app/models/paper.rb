class Paper < ActiveRecord::Base
  include AASM

  belongs_to :user
  has_many :annotations
  has_many :assignments

  has_many :reviewers, -> { where('assignments.role = ?', 'reviewer') }, :through => :assignments, :source => :user
  has_many :collaborators, -> { where('assignments.role = ?', 'collaborator') }, :through => :assignments, :source => :user

  # Which User is this currently for the attention of?
  belongs_to :fao, :class_name => "User", :foreign_key => "fao_id"

  scope :active, -> { where.not(state:'pending') }


  before_create :set_sha, :get_arxiv_details


  aasm column: :state do
    state :pending,          initial:true
    state :submitted
    state :under_review
    state :accepted
    state :rejected

    event :accept, after: :resolve_all_issues do
      transitions to: :accepted
    end

    event :assigned do
      transitions from: :submitted, to: :under_review
    end

  end

  def self.with_state(state = nil)
    if state
      where('state = ?', state)
    else
      all
    end
  end

  def issues
    annotations.root_annotations
  end

  def outstanding_issues
    annotations.where.not(state:'resolved')
  end

  def resolve_all_issues
    annotations.each(&:resolve!)
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


  def get_arxiv_details
    details          = Arxiv.get(self.arxiv_id.to_s)

    location         = details.links.select{|link| link.content_type=="application/pdf"}.first.url
    location = location + ".pdf" unless location.include? ".pdf"

    self.title       = details.title
    self.location    = location
    self.summary     = details.summary
    self.author_list = details.authors.collect{|a| a.name}.join(", ")
    rescue
      self.location  = "http://arxiv.org/pdf/#{self.arxiv_id}.pdf"
      logger.debug "couldn't find paper on arxiv"
  end

end
