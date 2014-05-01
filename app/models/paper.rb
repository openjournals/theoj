class Paper < ActiveRecord::Base
  belongs_to :user
  has_many :comments
  
  state_machine :initial => :pending do 
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
  
  def draft?
    state == "pending"
  end
end
