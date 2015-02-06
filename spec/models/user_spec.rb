require "rails_helper"

describe User do

  it "should initialize properly" do
    user = create(:user)

    assert !user.sha.nil?
    expect(user.sha.length).to eq(32)
  end

  describe "#editors" do

    it "should return editors" do
      user = create(:editor)
      create(:user)

      expect(User.editors).to eq([user])
    end

  end

  describe "#reviewer_of?" do

    it "should return correct reviewer assignments" do
      user = create(:user)
      paper = create(:submitted_paper)

      create(:assignment_as_reviewer, :user => user, :paper => paper)

      assert user.reviewer_of?(paper)
      assert !user.author_of?(paper)
      assert !user.collaborator_on?(paper)
    end

  end

  describe "#collaborator_on?" do

    it "should return correct collaborator assignments" do
      user = create(:user)
      paper = create(:submitted_paper)

      create(:assignment_as_collaborator, :user => user, :paper => paper)

      assert user.collaborator_on?(paper)
      assert !user.reviewer_of?(paper)
      assert !user.author_of?(paper)
    end

  end

  describe "#author_of?" do

    it "should know who the author is" do
      user = create(:user)
      paper = create(:paper, :user => user)

      assert user.author_of?(paper)
      assert !user.reviewer_of?(paper)
      assert !user.collaborator_on?(paper)
    end

  end

end