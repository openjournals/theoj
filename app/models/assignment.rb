class Assignment < ActiveRecord::Base

  before_create :set_initial_values

  belongs_to :user
  belongs_to :paper

  validates :role, inclusion:{ in:['submittor', 'collaborator', 'reviewer', 'editor'] }

  private

  def set_initial_values
    self.sha = SecureRandom.hex
  end

end
