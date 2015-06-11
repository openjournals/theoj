class NotificationMailer < ApplicationMailer

  def notification(user, paper, text, subject='Paper Updated')
    @paper = paper
    @link  = url_for(paper)
    @text  = text

    subject = "#{paper.title} - #{subject}"

    mail to:user, subject:subject
  end

end
