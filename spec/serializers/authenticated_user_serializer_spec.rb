require "rails_helper"

describe AuthenticatedUserSerializer do

  it "should have the correct keys" do
    user = create(:user)

    serializer = AuthenticatedUserSerializer.new(user)
    hash = hash_from_json(serializer.to_json)

    ["name", "email", "created_at", "picture", "sha", "editor", "admin"].each do |key|
      expect(hash).to include(key)
    end
  end

end
