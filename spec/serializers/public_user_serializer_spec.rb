require "rails_helper"

describe PublicUserSerializer do

  it "should have the correct keys" do
    user = create(:user)

    serializer = PublicUserSerializer.new(user)
    hash = hash_from_json(serializer.to_json)

    expect(hash.keys).to contain_exactly("name", "email", "created_at", "picture", "sha")
  end

end
