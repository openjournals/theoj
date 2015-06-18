class AssignmentSerializer < BaseSerializer

  attributes :sha,
             :role,
             :completed

  has_one   :user, serializer:PublicUserSerializer

  private

  def filter(*)
    results = super
    results = results - [:user]      unless object.make_user_info_public?(current_user)
    results = results - [:completed] unless object.use_completed?
    results
  end

end
