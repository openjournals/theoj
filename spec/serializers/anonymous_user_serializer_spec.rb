require "rails_helper"

describe AnonymousUserSerializer do

  # it "should have the correct keys" do
  #   user = create(:user)
  #
  #   serializer = AnonymousUserSerializer.new(user)
  #   hash = hash_from_json(serializer.to_json)
  #
  #   ["name", "sha"].each do |key|
  #     expect(hash).to include(key)
  #   end
  # end

  it "should not have public only keys" do
    user = create(:user)

    serializer = AnonymousUserSerializer.new(user)
    hash = hash_from_json(serializer.to_json)

    ["name", "sha", "created_at", "email", "picture"].each do |key|
      expect(hash).not_to include(key)
    end
  end

end
