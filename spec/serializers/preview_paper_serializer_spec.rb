require "rails_helper"

describe PreviewPaperSerializer do

  it "should initialize properly" do
    current_user = create(:user)
    user  = create(:user)

    paper = build(:paper, document_location:"http://example.com", title:"Teh awesomeness", submittor:user)
    serializer = PreviewPaperSerializer.new(paper, scope:current_user)
    hash = hash_from_json(serializer.to_json)

    expect(hash.keys).to contain_exactly("typed_provider_id",
                                         "document_location",
                                         "title",
                                         "summary",
                                         "authors",
                                         "is_existing",
                                         "is_self_owned")
  end

  context "self_owned field" do

    it "should be false if the current_user is not the owner" do
      current_user = create(:user)
      user  = create(:user)

      paper = create(:paper, submittor:user)
      serializer = PreviewPaperSerializer.new(paper, scope:current_user)
      hash = hash_from_json(serializer.to_json)

      expect(hash['is_self_owned']).to eq(false)
    end

    it "should be false if the current_user is the owner" do
      current_user = create(:user)

      paper = create(:paper, submittor:current_user)
      serializer = PreviewPaperSerializer.new(paper, scope:current_user)
      hash = hash_from_json(serializer.to_json)

      expect(hash['is_self_owned']).to eq(true)
    end

  end

  context "is_existing field" do

    it "should be true if the paper is saved" do
      paper = create(:paper)
      serializer = PreviewPaperSerializer.new(paper)
      hash = hash_from_json(serializer.to_json)

      expect(hash['is_existing']).to eq(true)
    end

    it "should be false if the paper is not saved" do
      paper = build(:paper)
      serializer = PreviewPaperSerializer.new(paper)
      hash = hash_from_json(serializer.to_json)

      expect(hash['is_existing']).to eq(false)
    end

  end

end
