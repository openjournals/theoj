class Paper < ActiveRecord::Base
  state_machine :initial => :submitted do 
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
  
  def resolve_all_issues
    # Do something awesome
  end
  
  def pretty_status
    state.humanize
  end

  def pretty_submission_date
    submitted_at.strftime("%-d %B %Y")
  end
end
