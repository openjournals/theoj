require "rails_helper"

describe PaperSerializer do

  it "should initialize properly" do
    user = create(:user)

    paper = Paper.new(location:"http://example.com", title:"Teh awesomeness", submittor:user)
    serializer = PaperSerializer.new(paper)
    hash = hash_from_json(serializer.to_json)

    expect(hash).to include("user_permissions", "location", "state",
                            "submitted_at", "title", "version",
                            "created_at", "pending_issues_count",
                            "sha", "assigned_users")
  end

  it "should serialize a list of assignments" do
    set_editor create(:editor, name:'An Editor')
    paper = create(:paper, submittor:create(:user, name:'The Submittor'))
    create(:assignment, :reviewer, paper:paper, user:create(:user,name:'The Reviewer'))

    serializer = PaperSerializer.new(paper)
    assignments = hash_from_json(serializer.to_json)['assigned_users']

    expect(assignments[0]['role']).to eq('editor')
    expect(assignments[0]['user']['name']).to eq('An Editor')
    expect(assignments[1]['role']).to eq('submittor')
    expect(assignments[1]['user']['name']).to eq('The Submittor')
    expect(assignments[2]['role']).to eq('reviewer')
    expect(assignments[2]['user']).to be_nil
  end

end
