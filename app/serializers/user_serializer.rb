class UserSerializer < ActiveModel::Serializer
  attributes :name,
             :created_at,
             :picture,
             :sha,
             :admin,
             :editor
end
