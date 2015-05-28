class PaperSerializer < BaseSerializer
  attributes :id,
             :arxiv_id,
             :version,
             :user_permissions,
             :location,
             :state,
             :submitted_at,
             :title,
             :version,
             :created_at,
             :pending_issues_count,
             :sha

  has_many :assigned_users

  def assigned_users
    object.assignments
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
