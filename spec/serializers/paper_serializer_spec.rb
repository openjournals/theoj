require "rails_helper"

describe PaperSerializer do
  it "should initialize properly" do
    paper = create(:paper)
    user = create(:user)

    serializer = PaperSerializer.new(Paper.create!(:location => "http://example.com", :title => "Teh awesomeness", :user => user))
    hash = hash_from_json(serializer.to_json)

    ["user_permissions", "location", "state", "submitted_at", "title", "version", "created_at", "pending_issues_count", "sha"].each do |key|
      assert hash["paper"].has_key?(key), "Missing key #{key}"
    end
  end
end
