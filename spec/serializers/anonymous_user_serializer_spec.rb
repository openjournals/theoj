require "rails_helper"

describe AnonymousUserSerializer do

  it "should have the correct keys" do
    user = create(:user)

    serializer = AnonymousUserSerializer.new(user)
    hash = hash_from_json(serializer.to_json)

    ["tag_name", "sha"].each do |key|
      expect(hash).to include(key)
    end
  end

  it "should not have public only keys" do
    user = create(:user)

    serializer = AnonymousUserSerializer.new(user)
    hash = hash_from_json(serializer.to_json)

    ["name", "created_at", "email", "picture"].each do |key|
      expect(hash).not_to include(key)
    end
  end

  it "should anonymize the name" do
    user = create(:user, name:'John Doe')

    serializer = AnonymousUserSerializer.new(user)
    hash = hash_from_json(serializer.to_json)

    expect(hash['tag_name']).to eq('JD')
  end

end
