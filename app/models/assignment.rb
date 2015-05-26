class Assignment < ActiveRecord::Base

  before_create  :set_initial_values
  before_destroy :check_for_annotations!

  belongs_to :user,        inverse_of: :assignments
  belongs_to :paper,       inverse_of: :assignments
  has_many   :annotations, inverse_of: :assignment

  validates :role, inclusion:{ in:['submittor', 'collaborator', 'reviewer', 'editor'] }

  private

  def set_initial_values
    self.sha = SecureRandom.hex
  end

  def check_for_annotations!
    if paper.annotations.any?{ |a| a.assignment == self }
      errors.add(:base, "cannot delete customer while orders exist")
      false
    end
  end

end
