class Assignment < ActiveRecord::Base
  belongs_to :user
  belongs_to :paper

  # TODO should add in validations for roles here (should be collaborator, reviewer, editor)
end
