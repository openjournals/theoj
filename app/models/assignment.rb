class Assignment < ActiveRecord::Base

  belongs_to :user,        inverse_of: :assignments
  belongs_to :paper,       inverse_of: :assignments
  has_many   :annotations, inverse_of: :assignment

  # set when the paper is being updated from an original
  attr_accessor :copied

  validates :role, inclusion:{ in:['submittor', 'collaborator', 'reviewer', 'editor'] }

  before_create  :set_initial_values
  before_destroy :check_for_annotations!

  # Using after commit since creating revisions happens in a transaction
  after_commit  :send_emails, on: :create

  def self.build_copy(original)
    # Note we don't copy the 'completed' field
    attrs = original.attributes.symbolize_keys.slice(:role, :user_id, :public)
    attrs[:copied] = true
    self.new attrs
  end

  def use_completed?
    role == 'reviewer'
  end

  #@mro, @todo Change to use CanCan?
  def make_user_info_public?(requesting_user)
    public? || requesting_user==self.user || (requesting_user && requesting_user.editor_of?(paper) )
  end

  private

  def set_initial_values
    self.sha = SecureRandom.hex

    if ! copied
      self.public = (role != 'reviewer')
    end

    true
  end

  def check_for_annotations!
    if paper.annotations.any?{ |a| a.assignment == self }
      errors.add(:base, "cannot delete customer while orders exist")
      false
    end
  end

  def send_emails
    # submittor emails are sent from the Paper
    return if role == 'submittor'

    # We need to send the assigned email if the record is not copied
    #   i.e. the user is assigned after the paper is updated
    if ! copied
      NotificationMailer.notification(user, paper,
                                      "You have been assigned to a paper as #{role.a_or_an} #{role}.",
                                      'Paper Assigned'
      ).deliver_later

    else
      NotificationMailer.notification(user, paper,
                                      "A paper that you are assigned to as #{role.a_or_an} #{role} has been updated.",
                                      'Paper Updated'
      ).deliver_later

    end

  end

end
