class Assignment < ActiveRecord::Base

  before_create :set_initial_values

  belongs_to :user,  inverse_of: :assignments
  belongs_to :paper, inverse_of: :assignments

  validates :role, inclusion:{ in:['submittor', 'collaborator', 'reviewer', 'editor'] }

  private

  def set_initial_values
    self.sha = SecureRandom.hex
  end

end
