class AssignmentSerializer < BaseSerializer

  attribute :role
  attribute :sha

  def serializable_object(*)
    super
  end

end
