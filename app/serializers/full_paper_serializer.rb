class FullPaperSerializer < PaperSerializer

  attributes :location

  has_many :assigned_users
  has_many :versions,       each_serialzier: BasicPaperSerializer

  def versions
    Paper.versions_for(object.arxiv_id)
  end

  def assigned_users
    object.assignments
  end

end
