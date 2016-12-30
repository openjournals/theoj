class FullPaperSerializer < PaperSerializer

  attributes :paper_id,
             :document_location

  has_many :assigned_users
  has_many :versions,     each_serializer: BasicPaperSerializer

  def paper_id
    object.id
  end

  def versions
    object.all_versions
  end

  def assigned_users
    object.assignments
  end

end
