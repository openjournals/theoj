# Preview all emails at http://localhost:3000/rails/mailers/notification_mailer
class NotificationMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/test
  def notification
    NotificationMailer.notification(User.first, Paper.first, 'This is a test e-mail.', 'Test')
  end

end
