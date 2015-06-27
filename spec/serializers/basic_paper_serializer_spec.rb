require "rails_helper"

describe BasicPaperSerializer do

  it "should initialize properly" do
    paper = Paper.new(location:"http://example.com", title:"Teh awesomeness")
    serializer = BasicPaperSerializer.new(paper)
    hash = hash_from_json(serializer.to_json)

    expect(hash.keys).to contain_exactly("provider_type", "provider_id", "version")
  end

end
