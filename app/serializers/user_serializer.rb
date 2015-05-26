class UserSerializer < BaseSerializer

  # Make sure that a user is never fully serialized because that would
  # Expose too much public information

  def initialize(*)
    raise "No serializer supplied for user"
  end

end
