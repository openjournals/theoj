class PaperSerializer < ActiveModel::Serializer
  attributes :id, :user_permissions, :location, :state, :submitted_at, :title, :version, :created_at, :pending_issues_count, :sha
  has_one :user
  has_many :reviewers

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
