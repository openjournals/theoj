# Patch for state_machine and Rails 4.2.0

module StateMachine
  module Integrations
    module ActiveModel
      public :around_validation
    end
  end
end