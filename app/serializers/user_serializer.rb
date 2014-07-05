class UserSerializer < ActiveModel::Serializer
  attributes :name, :created_at, :picture, :sha, :admin, :editor, :papers_as_reviewer, :papers_as_collaborator, :papers

end
