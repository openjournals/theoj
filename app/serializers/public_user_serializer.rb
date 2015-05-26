class PublicUserSerializer < ActiveModel::Serializer

  attributes :name,
             :email,
             :created_at,
             :picture,
             :sha

end
