require "rails_helper"

describe UserSerializer do

  it "should initialize properly" do
    user = create(:user)

    serializer = UserSerializer.new(user)
    hash = hash_from_json(serializer.to_json)

    ["name", "created_at", "picture", "sha", "admin", "editor"].each do |key|
      assert hash.has_key?(key), "Missing key #{key}"
    end
  end

end
