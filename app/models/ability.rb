class Ability
  include CanCan::Ability

  def initialize(user, paper=nil, comment=nil)
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
        
    # ============================
    # = Basic author permissions =
    # ============================
    
    # Can create papers
    can :create, Paper
    
    if paper
      # Can read papers if it's theirs or...
      can :read, Paper if user.author_of?(paper)

      can :destroy, Paper, :user_id => user.id
    
      # Don't let the user delete a paper once submitted.
      cannot :destroy, Paper unless paper.draft?
    
      # Can respond to comments from reviewers
      can :create, Comment if user.author_of?(paper) 
    end
    
    # ========================
    # = Reviewer permissions =
    # ========================
    
    if paper
      can :create, Comment if user.reviewer_of?(paper)
    
      # If they are a reviewer of the paper
      can :read, Paper if user.reviewer_of?(paper)
    end
    
    # They can change their comments unless there are responses to it
    # FIXME This seems weird to be checking if the comment exists
    if comment
      can :update, Comment unless comment.has_responses?
    end
    
    # Can only update their own comments
    can :update, Comment, :user_id => user.id
  end
end
