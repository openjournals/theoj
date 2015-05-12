class AssignmentSerializer < BaseSerializer

  attribute :role

  def serializable_object(*)
    super
  end

end
