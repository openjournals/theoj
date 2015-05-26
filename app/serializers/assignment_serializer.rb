class AssignmentSerializer < BaseSerializer

  attributes :sha,
             :role

  has_one   :user, serializer:PublicUserSerializer

  private

  def filter(*)
    if make_user_info_public?
      super
    else
      super - [:user]
    end
  end

  def make_user_info_public?
    object.role!='reviewer' || (current_user==object.user) || (current_user && current_user.editor_of?(object.paper) )
  end

end
