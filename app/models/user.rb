class User < ActiveRecord::Base
  has_many :assignments, inverse_of: :user
  has_many :assignments_as_collaborator, -> { where(role:'collaborator') }, class_name:'Assignment', inverse_of: :user
  has_many :assignments_as_reviewer,     -> { where(role:'reviewer') },     class_name:'Assignment', inverse_of: :user
  has_many :assignments_as_editor,       -> { where(role:'editor') },       class_name:'Assignment', inverse_of: :user

  # # Submitting author relationship with paper
  has_many :papers_as_submittor,    class_name:'Paper', inverse_of: :submittor, foreign_key:'submittor_id'
  has_many :papers_as_collaborator, through: :assignments_as_collaborator, source: :paper
  has_many :papers_as_reviewer,     through: :assignments_as_reviewer,     source: :paper
  has_many :papers_as_editor,       through: :assignments_as_editor,       source: :paper

  serialize :extra

  validates :email,
            format: {with:      /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i,
                     allow_nil: true,
                     message:   "Doesn't look like an email address"             }

  before_create :set_sha

  def self.from_omniauth(auth)
    where(provider: auth["provider"], uid: auth["uid"] ).first || create_from_omniauth(auth)
  end

  def self.create_from_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.name = auth["info"]["nickname"]
      user.picture = auth["info"]["image"]
      user.oauth_token = auth["credentials"]["token"]
      user.oauth_expires_at = Time.at(auth["credentials"]["expires_at"]) if auth["provider"] == "facebook"
      user.extra = auth
    end
  end

  def self.next_editor
    @editor ||=   where(editor:true).first
  end

  def reviewer_of?(paper)
    paper.reviewers.include?(self)
  end

  def editor_of?(paper)
    self.editor? && paper.editors.include?(self)
  end

  def collaborator_on?(paper)
    paper.collaborators.include?(self)
  end

  def author_of?(paper)
    paper.submittor == self
  end

  def role_for(paper)
    case
      when editor_of?(paper)
        'editor'
      when reviewer_of?(paper)
        'reviewer'
      when author_of?(paper)
        'author'
      when collaborator_on?(paper)
        'collaborator'
    end
  end

  def to_param
    sha
  end

  private

  def set_sha
    self.sha = SecureRandom.hex
  end

end
