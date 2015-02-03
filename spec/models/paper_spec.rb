require "rails_helper"

describe Paper do
  it "should initialize properly" do
    paper = create(:paper)

    assert !paper.sha.nil?
    expect(paper.sha.length).to eq(32)
    expect(paper.state).to eq("pending")
  end
end

describe Paper, "#with_scope" do
  it "should return properly scoped records" do
    paper = create(:submitted_paper)
    create(:paper)

    assert_equal Paper.count, 2
    assert_includes Paper.with_state('submitted'), paper
  end
end

describe Paper, ".resolve_all_issues" do
  it "should resolve any outstanding issues" do
    paper = create(:paper)
    3.times { create(:annotation, :paper => paper) }

    expect(paper.annotations.count).to eq(3)

    paper.resolve_all_issues

    expect( paper.outstanding_issues ).to be_empty
  end
end

describe Paper do
  it "should allow a user to create a Paper as author" do
    user = create(:user)
    ability = Ability.new(user)

    assert ability.can?(:create, Paper.create!(:user => user))
  end

  it "should allow a user to read a Paper as author" do
    user = create(:user)
    paper = create(:paper, :user => user)

    ability = Ability.new(user, paper)

    assert ability.can?(:read, paper)
  end

  it "should allow a user to update their own paper if it's not submitted" do
    user = create(:user)
    paper = create(:paper, :user => user)

    ability = Ability.new(user, paper)

    assert ability.can?(:update, paper)
  end

  it "should not allow a user to update their own paper if it has been submitted" do
    user = create(:user)
    paper = create(:submitted_paper, :user => user)

    ability = Ability.new(user, paper)

    assert ability.cannot?(:update, paper)
  end

  it "can destroy a draft paper that a user owns" do
    user = create(:user)
    paper = create(:paper, :user => user)

    ability = Ability.new(user, paper)

    assert ability.can?(:destroy, paper)
  end

  it "cannot destroy a draft paper that a user doesn't own" do
    user = create(:user)
    paper = create(:paper)

    ability = Ability.new(user, paper)

    assert ability.cannot?(:destroy, paper)
  end

  it "cannot destroy a submitted paper that a user owns" do
    user = create(:user)
    paper = create(:submitted_paper, :user => user)

    ability = Ability.new(user, paper)

    assert ability.cannot?(:destroy, paper)
  end
end

describe Paper, ".permisions_for_user" do
  it "should return correct permissions for paper for user" do
    user = create(:user)
    paper = create(:paper, :user => user)

    create(:assignment_as_reviewer, :user => user, :paper => paper)
    create(:assignment_as_collaborator, :user => user, :paper => paper)

    ["submittor", "collaborator", "reviewer"].each do |role|
      assert paper.permissions_for_user(user).include?(role), "Missing #{role}"
    end
  end

  it "should return correct permissions for paper for user as editor" do
    user = create(:editor)
    paper = create(:paper, :user => user)

    create(:assignment_as_reviewer, :user => user, :paper => paper)
    create(:assignment_as_collaborator, :user => user, :paper => paper)

    ["editor", "submittor", "collaborator", "reviewer"].each do |role|
      assert paper.permissions_for_user(user).include?(role), "Missing #{role}"
    end
  end
end

describe Paper, ".fao" do
  it "should know which user this paper is for the attention of" do
    user = create(:user)
    paper = create(:paper, :fao_id => user.id)

    expect(paper.fao).to eq(user)
    expect(user.papers_for_attention).to eq([paper])
  end
end
