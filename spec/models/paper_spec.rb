require "rails_helper"

describe Paper do

  it "should initialize properly" do
    paper = create(:paper)

    assert !paper.sha.nil?
    expect(paper.sha.length).to eq(32)
    expect(paper.state).to eq("submitted")
  end

  describe "construction" do

    it "Adds the submittor and editor as assignments" do
      editor    = set_editor
      submittor = create(:user)
      p = create(:paper, submittor:submittor)

      expect(p.submittor_assignment.user).to eq(submittor)
      expect(p.assignments.length).to eq(2)
      expect(p.assignments.first.role).to  eq('editor')
      expect(p.assignments.first.user).to  eq(editor)
      expect(p.assignments.second.role).to eq('submittor')
      expect(p.assignments.second.user).to eq(submittor)
    end

  end

  describe "::with_scope" do

    it "should return properly scoped records" do
      paper = create(:paper, :submitted)
      create(:paper)

      assert_equal Paper.count, 2
      assert_includes Paper.with_state('submitted'), paper
    end

  end

  describe "states" do

    context "begin_review event" do

      it "should succeed if the paper has reviewers" do
        paper = create(:paper, reviewer:true)
        paper.start_review!
      end

      it "should fail if the paper has no reviewers" do
        paper = create(:paper)
        expect { paper.start_review! }.to raise_exception(AASM::InvalidTransition)
      end

    end

  end

  describe "#resolve_all_issues" do

    it "should resolve any outstanding issues" do
      paper = create(:paper, :under_review)
      3.times { create(:annotation, paper:paper) }

      expect(paper.annotations.count).to eq(3)

      paper.resolve_all_issues

      expect( paper.outstanding_issues ).to be_empty
    end

  end

  describe "Abilities" do

    it "should allow a user to create a Paper as author" do
      user = create(:user)
      ability = Ability.new(user)

      assert ability.can?(:create, Paper.create!(submittor:user))
    end

    it "should allow a user to read a Paper as author" do
      user = create(:user)
      paper = create(:paper, submittor:user)

      ability = Ability.new(user, paper)

      assert ability.can?(:read, paper)
    end

    # it "should allow a user to update their own paper if it's not submitted" do
    #   user = create(:user)
    #   paper = create(:paper, submittor:user)
    #
    #   ability = Ability.new(user, paper)
    #
    #   assert ability.can?(:update, paper)
    # end

    it "should not allow a user to update their own paper" do
      user = create(:user)
      paper = create(:paper, :submitted, submittor:user)

      ability = Ability.new(user, paper)

      assert ability.cannot?(:update, paper)
    end

    # it "can destroy a draft paper that a user owns" do
    #   user = create(:user)
    #   paper = create(:paper, submittor:user)
    #
    #   ability = Ability.new(user, paper)
    #
    #   assert ability.can?(:destroy, paper)
    # end

    it "cannot destroy a draft paper that a user doesn't own" do
      user = create(:user)
      paper = create(:paper)

      ability = Ability.new(user, paper)

      assert ability.cannot?(:destroy, paper)
    end

    it "cannot destroy a submitted paper that a user owns" do
      user  = create(:user)
      paper = create(:paper, :submitted, submittor:user)

      ability = Ability.new(user, paper)

      assert ability.cannot?(:destroy, paper)
    end

    it "an editor can change the state of a paper" do
      user  = create(:editor)
      paper = create(:paper, :submitted, submittor:create(:user))

      ability = Ability.new(user, paper)

      expect(ability).to be_able_to(:start_review, paper)
    end

    it "an author cannot change the state of a paper" do
      user = create(:user)
      paper = create(:paper, :submitted, submittor:user)

      ability = Ability.new(user, paper)

      expect(ability).not_to be_able_to(:start_review, paper)
    end

    it "a reviewer cannot change the state of a paper" do
      user = create(:user)
      paper = create(:paper, :submitted, submittor:create(:user), reviewer:user )

      ability = Ability.new(user, paper)

      expect(ability).not_to be_able_to(:start_review, paper)
    end

    it "a reader cannot change the state of a paper" do
      user = create(:user)
      paper = create(:paper, :submitted, submittor:create(:user) )

      ability = Ability.new(user, paper)

      expect(ability).not_to be_able_to(:start_review, paper)
    end

  end

  describe "#permisions_for_user" do

    it "should return correct permissions for paper for user" do
      user = create(:user)
      paper = create(:paper, submittor:user)

      create(:assignment, :reviewer,     user:user, paper:paper)
      create(:assignment, :collaborator, user:user, paper:paper)

      ["submittor", "collaborator", "reviewer"].each do |role|
        assert paper.permissions_for_user(user).include?(role), "Missing #{role}"
      end
    end

    it "should return correct permissions for paper for user as editor" do
      user  = set_editor
      paper = create(:paper, submittor:user)

      create(:assignment, :reviewer,     user:user, paper:paper)
      create(:assignment, :collaborator, user:user, paper:paper)

      ["editor", "submittor", "collaborator", "reviewer"].each do |role|
        assert paper.permissions_for_user(user).include?(role), "Missing #{role}"
      end
    end

  end

  describe "#add_assignee" do

    it "should add the user as a reviewer" do
      user  = create(:user)
      paper = create(:paper)

      expect(paper.add_assignee(user,'reviewer')). to be_truthy
      expect(paper.reviewers.length).to eq(1)
      expect(paper.reviewers.first).to eq(user)
    end

    it "should fail if the user is the submittor" do
      user  = create(:user)
      paper = create(:paper, submittor:user)

      expect(paper.add_assignee(user,'reviewer')). to be_falsy
      expect(paper.reviewers).to be_empty
      expect(paper.errors).not_to be_empty
    end

    it "should fail if the user is a collaborator" do
      user  = create(:user)
      paper = create(:paper, collaborator:user)

      expect(paper.add_assignee(user,'reviewer')). to be_falsy
      expect(paper.reviewers).to be_empty
      expect(paper.errors).not_to be_empty
    end

    it "should fail if the user is already a reviewer" do
      user  = create(:user)
      paper = create(:paper, reviewer:user)

      expect(paper.add_assignee(user,'reviewer')). to be_falsy
      expect(paper.reviewers.length).to eq(1)
      expect(paper.errors).not_to be_empty
    end

  end

  describe "#remove_assignee" do

    it "should remove the reviewer" do
      user1 = create(:user)
      user2 = create(:user)
      paper = create(:paper, reviewer:[user1,user2])

      expect(paper.remove_assignee(user1, 'reviewer')).to be_truthy
      expect(paper.reviewers.length).to eq(1)
      expect(paper.reviewers.first).to eq(user2)
    end

    it "should fail if the user is not a reviewer" do
      user1 = create(:user)
      user2 = create(:user)
      paper = create(:paper, reviewer:user2)

      expect(paper.remove_assignee(user1, 'reviewer')).to be_falsy
      expect(paper.reviewers.length).to eq(1)
      expect(paper.reviewers.first).to eq(user2)
    end

    it "should fail if the user is a collaborator" do
      user  = create(:user)
      paper = create(:paper, collaborator:user)

      expect(paper.remove_assignee(user, 'reviewer')).to be_falsy
      expect(paper.collaborators.length).to eq(1)
      expect(paper.collaborators.first).to eq(user)
    end

  end

end
