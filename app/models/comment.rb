class Comment < ActiveRecord::Base
  state_machine :initial => :new do 
    state :new
    state :resolved
    state :challenged
    
  end
  
  def has_responses?
    false
  end
end
