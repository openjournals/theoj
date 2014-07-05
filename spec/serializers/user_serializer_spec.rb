require "rails_helper"

describe UserSerializer do
  it "should initialize properly" do
    user = create(:user)

    serializer = UserSerializer.new(user)
    hash = hash_from_json(serializer.to_json)

    ["name", "created_at", "picture", "sha", "admin", "editor", "papers_as_reviewer", "papers_as_collaborator"].each do |key|
      assert hash.has_key?(key), "Missing key #{key}"
    end
  end

  it "should return papers for user" do
    user = create(:user)
    paper = create(:paper, :user => user)

    serializer = UserSerializer.new(user)
    hash = hash_from_json(serializer.to_json)

    assert_equal hash['papers'].length, 1
  end

  it "should return assignments for user" do
    user = create(:user)
    paper = create(:paper, :user => user)
    create(:assignment_as_reviewer, :user => user)
    create(:assignment_as_collaborator, :user => user)

    serializer = UserSerializer.new(user)
    hash = hash_from_json(serializer.to_json)

    assert_equal hash['papers'].length, 1
    assert_equal hash['papers_as_reviewer'].length, 1
    assert_equal hash['papers_as_collaborator'].length, 1
  end
end
