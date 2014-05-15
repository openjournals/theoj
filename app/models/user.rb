class User < ActiveRecord::Base
  has_many :annotations
  has_many :assignments  
  has_many :papers_as_reviewer, -> { where('assignments.role = ?', 'reviewer') }, :through => :assignments, :source => :paper
  has_many :papers_as_editor, -> { where('assignments.role = ?', 'editor') }, :through => :assignments, :source => :paper
  has_many :papers_as_collaborator, -> { where('assignments.role = ?', 'collaborator') }, :through => :assignments, :source => :paper

  serialize :extra
    
  def self.from_omniauth(auth)
    where(auth.slice("provider", "uid")).first || create_from_omniauth(auth)
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
  
  def reviewer_of?(paper)
    # FIXME - would like this to be cleaner
    self.assignments.where(:paper_id => paper.id).any?
  end
  
  def author_of?(paper)
    # FIXME - this needs to model more than just the single user
    paper.user == self
  end
end
