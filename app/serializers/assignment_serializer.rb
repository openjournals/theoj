class AssignmentSerializer < BaseSerializer

  attributes :sha,
             :role,
             :completed

  has_one   :user, serializer:PublicUserSerializer

  private

  def filter(*)
    results = super
    results = results - [:user]      if ! make_user_info_public?
    results = results - [:completed] if object.role != 'reviewer'
    results
  end

  def make_user_info_public?
    #@todo rename method to inverse
    object.role!='reviewer' || (current_user==object.user) || (current_user && current_user.editor_of?(object.paper) )
  end

end
