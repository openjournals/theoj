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

      if user.author_of?(paper)
        # Can read papers if it's theirs or...
        can :read, Paper if user.author_of?(paper)

        # Can respond to annotations from reviewers
        # TODO this isn't actually defining a response to something
        can :create, Annotation

        # Can read their own annotations
        can :read, Annotation, user_id: user.id

        # Can read someone else's annotations
        can :read, Annotation

        can :update,   Paper unless paper.published? || paper.accepted?

      end

      can :destroy, Paper, user_id: user.id

      cannot :destroy, Paper

    end
  end

  def initialize_reviewer(user, paper)
    if paper && user.reviewer_of?(paper)
      # If they are a reviewer of the paper
      can :read, Paper

      can :create, Annotation
      can :read,   Annotation
    end

    can :complete,     Paper, assignments:{user_id:user.id, role:'reviewer'}
    can :make_public,  Paper, assignments:{user_id:user.id, role:'reviewer'}
  end

  def initialize_editor(user, paper)
    if paper && user.editor_of?(paper)
      can :create, Annotation

      # If they are an editor of the paper
      can :read,    Paper
      can :destroy, Paper
      can :update,  Paper

      can :read,   Annotation

      #Paper Transitions
      can :start_review, Paper
      can :accept,       Paper
      can :reject,       Paper

      can :create,       Assignment
      can :destroy,      Assignment

      can :destroy,      Annotation

      # State changes
      can [:start_review, :accept, :reject, :publish], Paper

      can [:unresolve, :dispute, :resolve],            Annotation
    end
  end

  def initialize_privileged(user)
    # Admins can do anything
    if user.admin?
      can :manage, :all
    end
  end

  def initialize_annotation(user, annotation)
    if annotation
      # They can change their annotations unless there are responses to it
      can :update, Annotation, :user_id => user.id unless annotation.has_responses?

      # Authors can't destroy annotations
      cannot :destroy, Annotation
    end

    can :view_annotations,  Paper, assignments:{user_id:user.id}
    can :annotate,          Paper, assignments:{user_id:user.id}
    can :comment,           Paper, assignments:{user_id:user.id}

    # State changes
    can [:unresolve, :dispute, :resolve],
        Annotation, assignment: { user_id: user.id }

  end

end
