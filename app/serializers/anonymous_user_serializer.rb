class AnonymousUserSerializer < BaseSerializer

  attributes :tag_name,
             :sha

  def tag_name
    object.anonymous_name
  end
  
end
