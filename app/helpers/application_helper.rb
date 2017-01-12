module ApplicationHelper

  def current_user_roles
    user = current_user

    if (!user)
      ''
    elsif user.admin? && user.editor?
      ' (Admin, Editor)'
    elsif user.admin?
      ' (Admin)'
    elsif user.editor?
      ' (Editor)'
    else
      ''
    end
  end

end
