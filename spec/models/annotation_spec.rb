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

  describe '#is_issue?' do

    it "should be true for a root annotation" do
      root_annotation = create(:root)
      expect(root_annotation.is_issue?).to be_truthy
    end

    it "should be true false for a reply" do
      reply_annotation = create(:reply)
      expect(reply_annotation.is_issue?).to be_falsy
    end

  end

  describe "State" do

    it "should initiallly be unresolved" do
      annotation = build(:issue)
      annotation.unresolve!
      expect(annotation).to be_unresolved
    end

    context "an issue" do

      let (:annotation) { build(:issue) }

      it "should be possible to resolve the annotation" do
        expect(annotation.may_resolve?).to eq(true)
        annotation.resolve!
        expect(annotation).to be_resolved
      end

      it "should be possible to dispute the annotation" do
        expect(annotation.may_dispute?).to eq(true)
        annotation.dispute!
        expect(annotation).to be_disputed
      end

      it "should be possible to unresolve the annotation" do
        annotation.dispute!

        expect(annotation.may_unresolve?).to eq(true)
        annotation.unresolve!
        expect(annotation).to be_unresolved
      end

    end

    context "a reply" do

      let (:annotation) { build(:reply) }

      it "should not be possible to resolve the annotation" do
        expect(annotation.may_resolve?).to eq(false)
        expect {
          annotation.resolve!
        }.to raise_error(AASM::InvalidTransition)
      end

      it "should not be possible to dispute the annotation" do
        expect(annotation.may_dispute?).to eq(false)
        expect {
          annotation.dispute!
        }.to raise_error(AASM::InvalidTransition)
      end

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

    it "AS AUTHOR: should not be able to dispute own annotation" do
      user = create(:user)
      paper = create(:submitted_paper, :user => user)
      annotation = create(:annotation, :user => user, :paper => paper)

      ability = Ability.new(user, paper, annotation)
      assert ability.cannot?(:dispute, annotation)
    end

    it "AS AUTHOR: should not be able to resolve own annotation" do
      user = create(:user)
      paper = create(:submitted_paper, :user => user)
      annotation = create(:annotation, :user => user, :paper => paper)

      ability = Ability.new(user, paper, annotation)
      assert ability.cannot?(:resolve, annotation)
    end

    it "AS AUTHOR: should not be able to unresolve own annotation" do
      user = create(:user)
      paper = create(:submitted_paper, :user => user)
      annotation = create(:annotation, :user => user, :paper => paper)

      ability = Ability.new(user, paper, annotation)
      assert ability.cannot?(:unresolve, annotation)
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

    it "WITHOUT ROLE: should not be possible to dispute annotations on someone else's paper" do
      user = create(:user)
      paper = create(:paper) # note user doesn't own paper
      ability = Ability.new(user, paper)
      annotation = create(:annotation, :paper => paper)

      assert ability.cannot?(:dispute, annotation)
    end

    it "WITHOUT ROLE: should not be possible to resolve annotations on someone else's paper" do
      user = create(:user)
      paper = create(:paper) # note user doesn't own paper
      ability = Ability.new(user, paper)
      annotation = create(:annotation, :paper => paper)

      assert ability.cannot?(:resolve, annotation)
    end

    it "WITHOUT ROLE: should not be possible to unresolve annotations on someone else's paper" do
      user = create(:user)
      paper = create(:paper) # note user doesn't own paper
      ability = Ability.new(user, paper)
      annotation = create(:annotation, :paper => paper)

      assert ability.cannot?(:unresolve, annotation)
    end

    it "AS REVIEWER: should be possible to annotate paper" do
      user = create(:user)
      paper = create(:paper)
      create(:assignment_as_reviewer, :user => user, :paper => paper)
      ability = Ability.new(user, paper)

      assert ability.can?(:create, Annotation.new(:paper => paper, :body => "Blah"))
    end

    it "AS REVIEWER: should be possible to dispute annotations" do
      user = create(:user)
      paper = create(:paper)
      create(:assignment_as_reviewer, :user => user, :paper => paper)
      ability = Ability.new(user, paper)

      assert ability.can?(:dispute, build(:annotation, paper:paper))
    end

    it "AS REVIEWER: should be possible to resolve paper" do
      user = create(:user)
      paper = create(:paper)
      create(:assignment_as_reviewer, :user => user, :paper => paper)
      ability = Ability.new(user, paper)

      assert ability.can?(:resolve, Annotation.new(:paper => paper, :body => "Blah"))
    end

    it "AS REVIEWER: should be possible to unresolve paper" do
      user = create(:user)
      paper = create(:paper)
      create(:assignment_as_reviewer, :user => user, :paper => paper)
      ability = Ability.new(user, paper)

      assert ability.can?(:unresolve, Annotation.new(:paper => paper, :body => "Blah"))
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

    it "AS EDITOR: should be possible to dispute annotation on paper" do
      editor = create(:editor)
      user = create(:user)
      paper = create(:paper, :user => user)
      annotation = create(:annotation, :user => user, :paper => paper)

      ability = Ability.new(editor, paper, annotation)
      assert ability.can?(:dispute, annotation)
    end

    it "AS EDITOR: should be possible to resolve annotation on paper" do
      editor = create(:editor)
      user = create(:user)
      paper = create(:paper, :user => user)
      annotation = create(:annotation, :user => user, :paper => paper)

      ability = Ability.new(editor, paper, annotation)
      assert ability.can?(:resolve, annotation)
    end

    it "AS EDITOR: should be possible to unresolve annotation on paper" do
      editor = create(:editor)
      user = create(:user)
      paper = create(:paper, :user => user)
      annotation = create(:annotation, :user => user, :paper => paper)

      ability = Ability.new(editor, paper, annotation)
      assert ability.can?(:unresolve, annotation)
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
