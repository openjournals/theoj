class IssuesSerializer < BaseSerializer
  attributes :id,
             :user_id,
             :paper_id,
             :state,
             :parent_id,
             :category, :body,
             :author,
             :created_at,
             :xStart,
             :xEnd,
             :yStart,
             :yEnd,
             :page

  has_many :responses

  def author
    {
      id:          object.user.id,
      role:       object.user.role_for(object.paper)
    }
  end

end
