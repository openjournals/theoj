require "rails_helper"

describe ArxivSerializer do

  it "should initialize properly" do
    current_user = create(:user)
    user  = create(:user)

    paper = Paper.new(location:"http://example.com", title:"Teh awesomeness", submittor:user)
    serializer = ArxivSerializer.new(paper, scope:current_user)
    hash = hash_from_json(serializer.to_json)

    expect(hash).to include("arxiv_url", "links", "title", "summary", "sha", "authors", "source", "self_owned")
  end

  it "should have a source properly" do
    current_user = create(:user)
    user  = create(:user)

    paper = Paper.new(location:"http://example.com", title:"Teh awesomeness", submittor:user)
    serializer = ArxivSerializer.new(paper, scope:current_user)
    hash = hash_from_json(serializer.to_json)

    expect(hash['source']).to eq('theoj')
  end

  context "self_owned properly" do

    it "should be false if the current_user is not the owner" do
      current_user = create(:user)
      user  = create(:user)

      paper = Paper.new(location:"http://example.com", title:"Teh awesomeness", submittor:user)
      serializer = ArxivSerializer.new(paper, scope:current_user)
      hash = hash_from_json(serializer.to_json)

      expect(hash['self_owned']).to eq(false)
    end

    it "should be false if the current_user is the owner" do
      current_user = create(:user)

      paper = Paper.new(location:"http://example.com", title:"Teh awesomeness", submittor:current_user)
      serializer = ArxivSerializer.new(paper, scope:current_user)
      hash = hash_from_json(serializer.to_json)

      expect(hash['self_owned']).to eq(true)
    end

  end

end
