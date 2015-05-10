class PublicUserSerializer < ActiveModel::Serializer

  attributes :name,
             :tag_name,
             :email,
             :created_at,
             :picture,
             :sha

  def tag_name
    object.anonymous_name
  end

end
