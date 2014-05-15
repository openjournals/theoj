class Comment < ActiveRecord::Base
  belongs_to :paper
  belongs_to :user

  has_many :responses, :class_name => "Comment", :foreign_key => "parent_id"
  belongs_to :parent, class_name: "Comment", :foreign_key => "parent_id"
  
  validates_presence_of :body, :paper_id

  state_machine :initial => :new do 
    state :new
    state :resolved
    state :challenged
  end
  
  def has_responses?
    responses.any?
  end
end
