require "rails_helper"

describe BasicPaperSerializer do

  it "should initialize properly" do
    paper = build(:paper, document_location:"https://example.com", title:"Teh awesomeness")
    serializer = BasicPaperSerializer.new(paper)
    hash = hash_from_json(serializer.to_json)

    expect(hash.keys).to contain_exactly("typed_provider_id")
  end

end
