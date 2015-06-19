class Ability
  include CanCan::Ability

  def initialize(user, paper=nil, annotation=nil)
    # HEADS UP - ordering matters here because of how CanCan defines abilities

    if user
      initialize_annotation(user, annotation)
      initialize_author(user, paper)
      initialize_collaborator(user, paper)
      initialize_reviewer(user, paper)
      initialize_editor(user, paper)
      initialize_privileged(user)
    end
  end
  
  def initialize_collaborator(user, paper)
    if paper
      can :read, Paper if user.collaborator_on?(paper)
      
      # Can read someone else's annotations
      can :read, Annotation if user.collaborator_on?(paper)
    end
  end

  def initialize_author(user, paper)
    # Can create papers
    can :create, Paper

    if paper
      # Can read papers if it's theirs or...
      can :read, Paper if user.author_of?(paper)

      can :destroy, Paper, :user_id => user.id

      cannot :update, Paper
      cannot :destroy, Paper

      # can :update, Paper, :user_id => user.id if paper.draft?

      # Can respond to annotations from reviewers
      # TODO this isn't actually defining a response to something
      can :create, Annotation if user.author_of?(paper)

      # Can read their own annotations
      can :read, Annotation, :user_id => user.id if user.author_of?(paper)

      # Can read someone else's annotations
      can :read, Annotation if user.author_of?(paper)

      # Cannot read annotations on paper that isn't their own
      cannot :read, Annotation if !user.author_of?(paper)
    end
  end

  def initialize_reviewer(user, paper)
    if paper && user.reviewer_of?(paper)
      can :create, Annotation

      # If they are a reviewer of the paper
      can :read, Paper

      can :read, Annotation

      # State changes
      can :unresolve, Annotation
      can :dispute,   Annotation
      can :resolve,   Annotation
    end

    can :complete,     Paper, assignments:{user_id:user.id, role:'reviewer'}
    can :make_public,  Paper, assignments:{user_id:user.id, role:'reviewer'}
  end

  def initialize_editor(user, paper)
    if paper && user.editor_of?(paper)
      can :create, Annotation

      # If they are a reviewer of the paper
      can :read, Paper

      can :read, Annotation

      # State changes
      can :unresolve, Annotation
      can :dispute,   Annotation
      can :resolve,   Annotation

      #Ppaer Transitions
      can :start_review, Paper
      can :accept,       Paper
      can :reject,       Paper
    end
  end

  def initialize_privileged(user)
    # Admins can do anything
    if user.admin?
      can :manage, :all

    # Editors can manage papers
    elsif user.editor?
      can :manage, Paper
      can :manage, Annotation
      can :manage, Assignment
    end
  end

  def initialize_annotation(user, annotation)
    if annotation
      # They can change their annotations unless there are responses to it
      can :update, Annotation, :user_id => user.id unless annotation.has_responses?

      # Authors can't destroy annotations
      cannot :destroy, Annotation
    end
  end
end
