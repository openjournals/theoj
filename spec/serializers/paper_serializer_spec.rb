require "rails_helper"

describe PaperSerializer do

  it "should initialize properly" do
    user = create(:user)

    paper = Paper.new(location:"http://example.com", title:"Teh awesomeness", user:user)
    serializer = PaperSerializer.new(paper)
    hash = hash_from_json(serializer.to_json)

    expect(hash).to include("user_permissions", "location", "state", "submitted_at", "title", "version", "created_at", "pending_issues_count", "sha", "user", "reviewers")
  end

  it "should serialize the user as public" do
    user = create(:user, name:'John Doe')

    paper = Paper.new(location:"http://example.com", title:"Teh awesomeness", user:user)
    serializer = PaperSerializer.new(paper)
    user_hash = hash_from_json(serializer.to_json)['user']

    expect(user_hash).to include('name', 'sha', 'email', 'created_at', 'picture')
    expect(user_hash['name']).to eq('John Doe')
  end

  it "should serialize the reviewers as anonymous when no user is logged in" do
    paper = Paper.new(location:"http://example.com")
    create(:assignment_as_reviewer, paper:paper, user:create(:user,name:'John Doe') )
    create(:assignment_as_reviewer, paper:paper, user:create(:user,name:'Mary Jane') )

    serializer = PaperSerializer.new(paper)
    reviewers_hash = hash_from_json(serializer.to_json)['reviewers']

    expect(reviewers_hash.first).to include('name', 'sha')
    expect(reviewers_hash.first).not_to include('email', 'created_at', 'picture')
    expect(reviewers_hash.first['name']).to eq('JD')

    expect(reviewers_hash.second).to include('name', 'sha')
    expect(reviewers_hash.second).not_to include('email', 'created_at', 'picture')
    expect(reviewers_hash.second['name']).to eq('MJ')
  end

  it "should serialize the reviewers as anonymous when a user is logged in" do
    user = create(:user)

    paper = Paper.new(location:"http://example.com")
    create(:assignment_as_reviewer, paper:paper, user:create(:user,name:'John Doe') )
    create(:assignment_as_reviewer, paper:paper, user:create(:user,name:'Mary Jane') )

    serializer = PaperSerializer.new(paper, scope:user)
    reviewers_hash = hash_from_json(serializer.to_json)['reviewers']

    expect(reviewers_hash.first).to include('name', 'sha')
    expect(reviewers_hash.first).not_to include('email', 'created_at', 'picture')
    expect(reviewers_hash.first['name']).to eq('JD')

    expect(reviewers_hash.second).to include('name', 'sha')
    expect(reviewers_hash.second).not_to include('email', 'created_at', 'picture')
    expect(reviewers_hash.second['name']).to eq('MJ')
  end

  it "should serialize the reviewers as public when an editor is logged in" do
    user = create(:editor)

    paper = Paper.new(location:"http://example.com")
    create(:assignment_as_reviewer, paper:paper, user:create(:user,name:'John Doe') )
    create(:assignment_as_reviewer, paper:paper, user:create(:user,name:'Mary Jane') )

    serializer = PaperSerializer.new(paper, scope:user)
    reviewers_hash = hash_from_json(serializer.to_json)['reviewers']

    expect(reviewers_hash.first).to include('name', 'sha', 'email', 'created_at', 'picture')
    expect(reviewers_hash.first['name']).to eq('John Doe')

    expect(reviewers_hash.second).to include('name', 'sha', 'email', 'created_at', 'picture')
    expect(reviewers_hash.second['name']).to eq('Mary Jane')
  end

end
