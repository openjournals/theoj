class PublicUserSerializer < BasicUserSerializer

  attributes :email,
             :created_at,
             :picture,
             :sha

end
