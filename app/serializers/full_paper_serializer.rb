class FullPaperSerializer < PaperSerializer

  attributes :location

  has_many :assigned_users
  has_many :versions,       each_serialzier: BasicPaperSerializer

  def versions
    object.all_versions
  end

  def assigned_users
    object.assignments
  end

end
