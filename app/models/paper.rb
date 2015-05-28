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

  scope :active, -> { ! superceded }

  before_create :set_initial_values, :create_assignments

  validates :submittor,
            presence: true

  aasm column: :state do
    state :submitted,          initial:true
    state :under_review
    state :superceded
    state :accepted
    state :rejected

    event :start_review, guard: :has_reviewers? do
      transitions from: :submitted,
                  to:   :under_review
    end

    event :supercede do
      transitions from: [:submitted, :under_review],
                  to:   :superceded
    end

    event :accept, before: :resolve_all_issues do
      transitions from: :under_review,
                  to:   :accepted
    end
    event :reject do
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

  def self.new_for_arxiv_id(arxiv_id, attributes={})
    begin
      arxiv_doc = Arxiv.get(arxiv_id.to_s)
    rescue Arxiv::Error::ManuscriptNotFound
      raise ActiveRecord::RecordNotFound
    end

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
        new_paper.assignments.build(role:a.role, user:a.user)
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
    self.sha = SecureRandom.hex
    self.submitted_at = Time.now
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

  def has_reviewers?
    reviewers.any?
  end

end
