class PaperSerializer < BaseSerializer
  attributes :id,
             :user_permissions,
             :location,
             :state,
             :submitted_at,
             :title,
             :version,
             :created_at,
             :pending_issues_count,
             :sha

  has_one  :user,       serializer:PublicUserSerializer
  has_many :reviewers

  def reviewers
    serializer_klass = UserSerializer.serialization_class(current_user)

    object.reviewers.map do |reviewer|
      serializer_klass.new(reviewer)
    end
  end

  def user_permissions
    if scope
      object.permissions_for_user(scope)
    else
      []
    end
  end

  def pending_issues_count
    object.outstanding_issues.count
  end

end
