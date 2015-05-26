require "rails_helper"

describe User do

  it "should initialize properly" do
    user = create(:user)

    assert !user.sha.nil?
    expect(user.sha.length).to eq(32)
  end

  describe "#reviewer_of?" do

    it "should return correct reviewer assignments" do
      user = create(:user)
      paper = create(:paper, :submitted)

      create(:assignment, :reviewer, user:user, paper:paper)

      assert user.reviewer_of?(paper)
      assert !user.author_of?(paper)
      assert !user.collaborator_on?(paper)
    end

  end

  describe "#collaborator_on?" do

    it "should return correct collaborator assignments" do
      user  = create(:user)
      paper = create(:paper, :submitted)

      create(:assignment, :collaborator, user:user, paper:paper)

      assert user.collaborator_on?(paper)
      assert !user.reviewer_of?(paper)
      assert !user.author_of?(paper)
    end

  end

  describe "#author_of?" do

    it "should know who the author is" do
      user = create(:user)
      paper = create(:paper, submittor:user)

      assert user.author_of?(paper)
      assert !user.reviewer_of?(paper)
      assert !user.collaborator_on?(paper)
    end

  end

  describe "#editor_of?" do

    it "should know who the editor is" do
      user = create(:user)

      editor1 = set_editor
      paper1 = create(:paper, submittor:user)
      paper2 = create(:paper, submittor:user)

      editor2 = set_editor
      paper3 = create(:paper, submittor:user)

      assert editor1.editor_of?(paper1)
      assert editor1.editor_of?(paper2)
      assert !editor1.editor_of?(paper3)
      assert !editor1.reviewer_of?(paper1)
      assert !editor1.collaborator_on?(paper1)
    end

  end

end