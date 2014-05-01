class Comment < ActiveRecord::Base
  belongs_to :paper
  belongs_to :user
  
  state_machine :initial => :new do 
    state :new
    state :resolved
    state :challenged
    
  end
  
  def has_responses?
    false
  end
end
