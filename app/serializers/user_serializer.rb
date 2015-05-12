class UserSerializer < BaseSerializer

  def self.serialization_class(authenticated_user)
    authenticated_user && authenticated_user.editor ? PublicUserSerializer : AnonymousUserSerializer
  end

  # Make sure that a user is never fully serialized because that would
  # Expose too much public information

  def initialize(*)
    raise "No serializer supplied for user"
  end

end
