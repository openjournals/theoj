class PaperSerializer < BaseSerializer

  attributes :paper_id,
             :provider_type,
             :provider_id,
             :version,
             :user_permissions,
             :state,
             :submitted_at,
             :title,
             :pending_issues_count

  has_one    :submittor, serializer:BasicUserSerializer

  #@mro #@todo - change references to this in Polymer annotations
  def paper_id
    object.id
  end

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
