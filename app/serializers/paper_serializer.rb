class PaperSerializer < BaseSerializer

  attributes :id,
             :arxiv_id,
             :version,
             :user_permissions,
             :state,
             :submitted_at,
             :title,
             :pending_issues_count,
             :sha

  has_one    :submittor, serializer:BasicUserSerializer

  def submitted_at
    object.created_at
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
