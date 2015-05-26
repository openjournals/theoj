class AnnotationSerializer < BaseSerializer
  attributes :id,
             :paper_id,
             :state,
             :parent_id,
             :body,
             :assignment,
             :created_at,
             :page,
             :xStart,
             :xEnd,
             :yStart,
             :yEnd

  has_many :responses

  def assignment
    object.assignment.sha
  end

end
