require "rails_helper"

describe PaperSerializer do

  it "should serialize properly" do
    user = create(:user)

    paper = build(:paper, document_location:"https://example.com", title:"Teh awesomeness", submittor:user)
    serializer = PaperSerializer.new(paper)
    hash = hash_from_json(serializer.to_json)

    expect(hash.keys).to contain_exactly("typed_provider_id",
                                         "user_permissions", "state",
                                         "submitted_at", "title",
                                         "pending_issues_count",
                                         "submittor"
                         )
  end

  it "should serialize the submittor properly" do
    user = create(:user)

    paper = build(:paper, submittor:user)
    serializer = PaperSerializer.new(paper)
    hash = hash_from_json(serializer.to_json)

    expect(hash['submittor'].keys).to contain_exactly("name")
  end

end
