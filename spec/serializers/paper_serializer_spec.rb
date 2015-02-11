require "rails_helper"

describe PaperSerializer do
  it "should initialize properly" do
    user = create(:user)

    paper = Paper.new(location:"http://example.com", title:"Teh awesomeness", user:user)
    serializer = PaperSerializer.new(paper)
    hash = hash_from_json(serializer.to_json)

    expect(hash).to include("user_permissions", "location", "state", "submitted_at", "title", "version", "created_at", "pending_issues_count", "sha")
  end
end
