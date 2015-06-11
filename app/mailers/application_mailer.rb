class ApplicationMailer < ActionMailer::Base
  layout  'mailer'

  def mail(headers = {}, &block)
    set_users(headers)
    @subject = headers[:subject] = "[TheOJ] #{headers[:subject]}"

    if headers[:to].present?
      super
    end
  end

  def full_email_for_user(user)
    if user.name.present? && user.email.present?
      %("#{user.name}" <#{user.email}>)
    else
      user.email
    end
  end

  private

  def set_users(headers)
    raise "No 'to' parameter supplied" unless headers[:to]

    users = Array(headers[:to])
    raise "'to' parameter must be a user" unless users.first.is_a?(User)
    @user = users.first

    users = users.map do |user|
      user.is_a?(User) ? full_email_for_user(user) : user
    end.compact

    headers[:to] = users
  end

end
