class AnonymousUserSerializer < BaseSerializer

  attributes :name,
             :sha

  def name
    object.anonymous_name
  end
  
end
