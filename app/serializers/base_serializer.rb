
class BaseSerializer < ActiveModel::Serializer

  def current_user
    scope
  end

end
