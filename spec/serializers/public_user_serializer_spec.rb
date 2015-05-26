require "rails_helper"

describe PublicUserSerializer do

  it "should have the correct keys" do
    user = create(:user)

    serializer = PublicUserSerializer.new(user)
    hash = hash_from_json(serializer.to_json)

    ["name", "email", "created_at", "picture", "sha"].each do |key|
      expect(hash).to include(key)
    end
  end

end
