require "rails_helper"

describe BasicUserSerializer do

  it "should have the correct keys" do
    user = create(:user)

    serializer = BasicUserSerializer.new(user)
    hash = hash_from_json(serializer.to_json)

    expect(hash.keys).to contain_exactly('name')
  end

end
