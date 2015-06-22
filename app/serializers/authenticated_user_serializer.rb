class AuthenticatedUserSerializer < ActiveModel::Serializer

  attributes :name,
             :email,
             :created_at,
             :picture,
             :sha,
             :editor,
             :admin,
             :has_papers_as_submittor,
             :has_papers_as_reviewer,
             :has_papers_as_editor

  def has_papers_as_submittor
    object.papers_as_submittor.any?
  end

  def has_papers_as_reviewer
    object.assignments_as_reviewer.any?
  end

  def has_papers_as_editor
    object.assignments_as_editor.any?
  end

end
