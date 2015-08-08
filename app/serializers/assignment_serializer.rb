class AssignmentSerializer < BaseSerializer

  attributes :sha,
             :role,
             :public,
             :completed,
             :reviewer_accept


  has_one   :user, serializer:PublicUserSerializer

  private

  def filter(*)
    results = super
    results = results - [:user]            unless object.make_user_info_public?(current_user)
    results = results - [:completed]       unless object.use_completed?
    results = results - [:reviewer_accept] unless object.use_completed? && object.completed?
    results
  end

end
