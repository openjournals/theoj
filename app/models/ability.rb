class Ability
  include CanCan::Ability

  def initialize(user, paper=nil, comment=nil)
    # ============================
    # = Basic author permissions =
    # ============================
    
    # Can create papers
    can :create, Paper
    
    if paper
      # Can read papers if it's theirs or...
      can :read, Paper if user.author_of?(paper)

      can :destroy, Paper, :user_id => user.id
      
      can :update, Paper, :user_id => user.id if paper.draft?

      # Don't let the user delete a paper once submitted.
      cannot :destroy, Paper unless paper.draft?
    
      # Can respond to comments from reviewers
      can :create, Comment if user.author_of?(paper) 
      
      # Can read their own comments
      can :read, Comment, :user_id => user.id if user.author_of?(paper) 
      
      # Can read someone else's comments
      can :read, Comment if user.author_of?(paper)
      
      # Cannot read comments on paper that isn't their own
      cannot :read, Comment if !user.author_of?(paper)
    end
    
    # ========================
    # = Reviewer permissions =
    # ========================
    
    if paper
      can :create, Comment if user.reviewer_of?(paper)
    
      # If they are a reviewer of the paper
      can :read, Paper if user.reviewer_of?(paper)
      
      can :read, Comment if user.reviewer_of?(paper)
    end
    
    # FIXME This seems weird to be checking if the comment exists
    if comment
      # They can change their comments unless there are responses to it
      can :update, Comment, :user_id => user.id unless comment.has_responses?
      
      # Authors can't destroy comments
      cannot :destroy, Comment
    end
    
    
    # ======================
    # = Admins and editors =
    # ======================

    # Admins can do anything
    if user.admin?
      can :manage, :all
    
    # Editors can manage papers
    elsif user.editor?
      can :manage, Paper
      can :manage, Comment
    end
  end
end
