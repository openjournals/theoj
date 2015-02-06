require "rails_helper"

describe Annotation do

  describe '#responses' do

    it "should return responses" do
      paper = create(:submitted_paper)
      first_annotation = create(:annotation, :paper => paper)
      second_annotation = create(:annotation, :parent_id => first_annotation.id)

      assert first_annotation.has_responses?
      assert_equal second_annotation.parent, first_annotation
    end

  end

  describe "Abilities" do

    it "AS AUTHOR: should be able to create an annotation on own paper" do
      user = create(:user)
      paper = create(:submitted_paper, :user => user)
      ability = Ability.new(user, paper)

      assert ability.can?(:create, Annotation.new(:paper_id => paper, :body => "Blah"))
    end

    it "AS AUTHOR: should be possible to read their own annotations on their paper" do
      user = create(:user)
      paper = create(:submitted_paper, :user => user)
      annotation = create(:annotation, :user => user, :paper => paper)
      ability = Ability.new(user, paper, annotation)

      assert ability.can?(:read, annotation)
    end

    it "AS AUTHOR: should be possible to read someone else's annotations on their paper" do
      user = create(:user)
      paper = create(:submitted_paper, :user => user)
      commentor = create(:user)
      annotation = create(:annotation, :paper => paper, :user => commentor)

      ability = Ability.new(user, paper, annotation)
      assert ability.can?(:read, annotation)
    end

    it "AS AUTHOR: should not be able to update annotation if there are responses" do
      editor = create(:editor)
      user = create(:user)
      paper = create(:submitted_paper, :user => user)

      annotation_1 = create(:annotation, :user => user, :paper => paper)
      annotation_2 = create(:annotation, :user => editor, :paper => paper, :parent_id => annotation_1.id)

      ability = Ability.new(user, paper, annotation_1)
      assert ability.cannot?(:update, annotation_1)
    end

    it "AS AUTHOR: should not be able to delete own annotations" do
      user = create(:user)
      paper = create(:submitted_paper, :user => user)
      annotation = create(:annotation, :user => user, :paper => paper)

      ability = Ability.new(user, paper, annotation)
      assert ability.cannot?(:destroy, annotation)
    end

    it "WITHOUT ROLE: should not be possible to annotate someone else's paper" do
      user = create(:user)
      paper = create(:paper)
      ability = Ability.new(user, paper)

      assert ability.cannot?(:create, Annotation.new(:paper => paper, :body => "Blah"))
    end

    it "WITHOUT ROLE: should not be possible to read annotations on someone else's paper" do
      user = create(:user)
      paper = create(:paper) # note user doesn't own paper
      ability = Ability.new(user, paper)
      annotation = create(:annotation, :paper => paper)

      assert ability.cannot?(:read, annotation)
    end

    it "AS REVIEWER: should be possible to annotate paper" do
      user = create(:user)
      paper = create(:paper)
      create(:assignment_as_reviewer, :user => user, :paper => paper)
      ability = Ability.new(user, paper)

      assert ability.can?(:create, Annotation.new(:paper => paper, :body => "Blah"))
    end

    it "AS EDITOR: should be possible to annotate paper" do
      user = create(:editor)
      paper = create(:paper)

      ability = Ability.new(user, paper)

      assert ability.can?(:create, Annotation.new(:paper => paper, :body => "Blah"))
    end

    it "AS EDITOR: should be possible to read annotation on paper" do
      editor = create(:editor)
      user = create(:user)
      paper = create(:paper, :user => user)
      annotation = create(:annotation, :user => user, :paper => paper)

      ability = Ability.new(editor, paper, annotation)
      assert ability.can?(:read, annotation)
    end

    it "AS EDITOR: should be possible to delete annotations" do
      editor = create(:editor)
      user = create(:user)
      paper = create(:paper, :user => user)
      annotation = create(:annotation, :user => user, :paper => paper)

      ability = Ability.new(editor, paper, annotation)
      assert ability.can?(:destroy, annotation)
    end

  end

end
