class AuthenticatedUserSerializer < ActiveModel::Serializer

  attributes :name,
             :email,
             :created_at,
             :picture,
             :sha,
             :editor,
             :admin

end
