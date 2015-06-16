class Assignment < ActiveRecord::Base

  belongs_to :user,        inverse_of: :assignments
  belongs_to :paper,       inverse_of: :assignments
  has_many   :annotations, inverse_of: :assignment

  # set when the paper is being updated from an original
  attr_accessor :updated

  validates :role, inclusion:{ in:['submittor', 'collaborator', 'reviewer', 'editor'] }

  before_create  :set_initial_values
  before_destroy :check_for_annotations!

  # Using after commit since creating revisions happens in a transaction
  after_commit  :send_emails, on: :create

  private

  def set_initial_values
    self.sha = SecureRandom.hex
    self.public = role != 'reviewer'
    true
  end

  def check_for_annotations!
    if paper.annotations.any?{ |a| a.assignment == self }
      errors.add(:base, "cannot delete customer while orders exist")
      false
    end
  end

  def send_emails
    # submittor emails are sent from Paper
    return if role == 'submittor'

    if updated
      NotificationMailer.notification(user, paper,
                                      "A paper that you are assigned to as #{role.a_or_an} #{role} has been updated.",
                                      'Paper Updated'
      ).deliver_later

    else
      NotificationMailer.notification(user, paper,
                                      "You have been assigned to a paper as #{role.a_or_an} #{role}.",
                                      'Paper Assigned'
      ).deliver_later

    end

  end

end
