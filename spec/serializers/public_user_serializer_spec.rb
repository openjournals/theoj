require "rails_helper"

describe PublicUserSerializer do

  it "should have the correct keys" do
    user = create(:user)

    serializer = PublicUserSerializer.new(user)
    hash = hash_from_json(serializer.to_json)

    ["name", "tag_name", "email", "created_at", "picture", "sha"].each do |key|
      expect(hash).to include(key)
    end
  end

  it "should return the full name and the tag name" do
    user = create(:user, name:'John Doe')

    serializer = PublicUserSerializer.new(user)
    hash = hash_from_json(serializer.to_json)

    expect(hash['name']).to eq('John Doe')
    expect(hash['tag_name']).to eq('JD')
  end

end
