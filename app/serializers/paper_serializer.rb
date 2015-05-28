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
