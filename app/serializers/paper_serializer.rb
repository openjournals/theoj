class PaperSerializer < ActiveModel::Serializer
  attributes :id, :user_permisions, :location, :state, :submitted_at, :title, :version, :created_at, :pending_issues_count, :sha
  has_one :user

  def user_permisions
    if current_user
      object.permisions_for_user current_user
    else
      []
    end
  end

  def pending_issues_count
    object.outstanding_issues.count
  end

end
