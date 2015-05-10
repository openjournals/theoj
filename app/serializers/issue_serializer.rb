class IssueSerializer < BaseSerializer
  attributes :id,
             :paper_id,
             :state,
             :parent_id,
             :body,
             :author,
             :created_at,
             :page,
             :xStart,
             :xEnd,
             :yStart,
             :yEnd

  has_many :responses

  def author
    serializer_klass = UserSerializer.serialization_class(current_user)
    serializer_klass.new(object.user)
  end

end
