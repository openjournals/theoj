class User < ActiveRecord::Base
  has_many :annotations
  has_many :assignments

  # Submitting author relationship with paper
  has_many :papers
  has_many :papers_as_reviewer, -> { where('assignments.role = ?', 'reviewer') }, :through => :assignments, :source => :paper
  has_many :papers_as_collaborator, -> { where('assignments.role = ?', 'collaborator') }, :through => :assignments, :source => :paper
  has_many :papers_for_attention, :foreign_key => 'fao_id', :class_name => "Paper"

  scope :editors, -> { where(:editor => true) }

  serialize :extra

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

  def anonymous_name
    parts = name.upcase.split(/\W+/)
    case parts.length
      when 0
        nil
      when 1
        parts.first[0]
      else
        parts.first[0] + parts.last[0]
    end
  end

  def reviewer_of?(paper)
    papers_as_reviewer.include?(paper)
  end

  def editor_of?(paper)
    self.editor?
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

  def papers_as_editor
    if self.editor?
      return Paper.active
    else
      return []
    end
  end

  def collaborator_on?(paper)
    papers_as_collaborator.include?(paper)
  end

  def author_of?(paper)
    paper.user == self
  end

  def to_param
    sha
  end

  private

  def set_sha
    self.sha = SecureRandom.hex
  end
end
