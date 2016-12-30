require "rails_helper"

describe Annotation do

  describe '#responses' do

    it "should return responses" do
      paper = create(:paper, :submitted)
      first_annotation  = create(:annotation,  paper:paper)
      second_annotation = create(:annotation,  paper:paper, parent:first_annotation)

      first_annotation.reload

      assert first_annotation.has_responses?
      assert_equal second_annotation.parent, first_annotation
    end

  end

  it "should set the paper from the parent if a parent is provided but no paper" do
    paper = create(:paper)
    annotation1 = create(:annotation, paper:paper)
    annotation2 = Annotation.create!(body:'Second Annotation', parent:annotation1, assignment:paper.assignments.first)

    expect(annotation2.paper).to eq(paper)
  end

  describe '#is_issue?' do

    it "should be true for a root annotation" do
      root_annotation = create(:root)
      expect(root_annotation.is_issue?).to be_truthy
    end

    it "should be true false for a reply" do
      reply_annotation = create(:response)
      expect(reply_annotation.is_issue?).to be_falsy
    end

  end

  describe "State" do

    it "should initiallly be unresolved" do
      annotation = build(:issue, paper:build(:paper, :under_review) )
      annotation.unresolve!
      expect(annotation).to be_unresolved
    end

    context "an issue" do

      let (:annotation) { build(:issue, paper:create(:paper, :under_review)) }

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

      let (:annotation) { build(:response) }

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

    context "if the paper is under review" do

      it "should be possible to resolve the annotation" do
        annotation = build(:issue, paper:create(:paper, :under_review))
        expect(annotation.may_resolve?).to eq(true)
        annotation.resolve!
        expect(annotation).to be_resolved
      end

      it "should be possible to dispute the annotation" do
        annotation = build(:issue, paper:create(:paper, :under_review))
        expect(annotation.may_dispute?).to eq(true)
        annotation.dispute!
        expect(annotation).to be_disputed
      end

      it "should be possible to unresolve the annotation" do
        annotation = build(:issue, :disputed, paper:create(:paper, :under_review))
        expect(annotation.may_unresolve?).to eq(true)
        annotation.unresolve!
        expect(annotation).to be_unresolved
      end

    end

    context "for any other paper state" do

      Paper.aasm.states.each do |state|
        next if state.name == :under_review

        it "should not be possible to resolve the annotation when the paper is #{state.name}" do
          annotation = build(:issue, paper:create(:paper, state:state.name))
          expect(annotation.may_resolve?).to eq(false)
          expect {
            annotation.resolve!
          }.to raise_error(AASM::InvalidTransition)
          expect(annotation).not_to be_resolved
        end

        it "should not be possible to dispute the annotation when the paper is #{state.name}" do
          annotation = build(:issue, paper:create(:paper, state:state.name))
          expect(annotation.may_dispute?).to eq(false)
          expect {
            annotation.dispute!
          }.to raise_error(AASM::InvalidTransition)
          expect(annotation).not_to be_disputed
        end

        it "should not be possible to unresolve the annotation when the paper is #{state.name}" do
          annotation = build(:issue, :disputed, paper:create(:paper, :under_review))
          annotation.paper.state = state.name
          expect(annotation.may_unresolve?).to eq(false)
          expect {
            annotation.unresolve!
          }.to raise_error(AASM::InvalidTransition)
          expect(annotation).not_to be_unresolved
        end

      end

    end

    context "if the paper is being accepted" do

      it "should be possible to resolve the annotation" do
        paper = create(:paper, :review_completed)
        annotation = create(:issue, paper:paper)
        expect(annotation).not_to be_resolved

        paper.accept!

        expect(annotation.reload).to be_resolved
      end

    end

  end

  describe "Abilities" do

    context "creating a new annotation on a paper" do

      it "AS AUTHOR: should be able to create an annotation on own paper" do
        user = create(:user)
        paper = create(:paper, :submitted, submittor:user)
        ability = Ability.new(user, paper)

        expect(ability).to be_able_to(:create,   Annotation)
        expect(ability).to be_able_to(:annotate, paper)
      end

      it "WITHOUT ROLE: should not be possible to annotate someone else's paper" do
        user = create(:user)
        paper = create(:paper)
        ability = Ability.new(user, paper)

        assert ability.cannot?(:create, Annotation.new(paper: paper, body: "Blah"))
      end

      it "AS REVIEWER: should be possible to annotate paper" do
        user       = create(:user)
        paper      = create(:paper)
        assignment = create(:assignment, :reviewer, user:user, paper:paper)

        ability    = Ability.new(user, paper)

        assert ability.can?(:create, Annotation.new(paper: paper, assignment: assignment, body: "Blah"))
      end

      it "AS EDITOR: should be possible to annotate paper" do
        editor = create(:editor)
        paper = create(:paper, editor: editor)

        ability = Ability.new(editor, paper)

        assert ability.can?(:create, Annotation.new(paper: paper, body: "Blah"))
      end

    end

    context "Reading an annotation" do

      it "AS AUTHOR: should be possible to read their own annotations on their paper" do
        user = create(:user)
        paper = create(:paper, :submitted, submittor:user)
        annotation = create(:annotation, paper:paper)
        ability = Ability.new(user, paper, annotation)

        assert ability.can?(:read, annotation)
      end

      it "AS AUTHOR: should be possible to read someone else's annotations on their paper" do
        user      = create(:user)
        paper     = create(:paper, :submitted, submittor:user)
        commentor = create(:user)
        assign    = create(:assignment, paper:paper, user:commentor)
        annotation = create(:annotation, paper:paper, assignment:assign)

        ability = Ability.new(user, paper, annotation)
        assert ability.can?(:read, annotation)
      end

      it "WITHOUT ROLE: should not be possible to read annotations on someone else's paper" do
        user = create(:user)
        paper = create(:paper) # note user doesn't own paper
        ability = Ability.new(user, paper)
        annotation = create(:annotation, paper: paper)

        assert ability.cannot?(:read, annotation)
      end

      it "AS EDITOR: should be possible to read annotation on paper" do
        editor = create(:editor)
        user   = create(:user)
        paper  = create(:paper, submittor:user, editor:editor)
        annotation = create(:annotation, paper: paper)

        ability = Ability.new(editor, paper, annotation)
        assert ability.can?(:read, annotation)
      end

    end

    context "Updating an annotation" do

      it "AS AUTHOR: should not be able to update annotation if there are responses" do
        editor = create(:editor)
        user   = create(:user)
        paper  = create(:paper, :submitted, submittor:user)

        annotation_1 = create(:annotation, user:user,   paper:paper)
        annotation_2 = create(:annotation, user:editor, paper:paper, parent:annotation_1)

        annotation_1.reload

        ability = Ability.new(user, paper, annotation_1)
        assert ability.cannot?(:update, annotation_1)
      end

    end

    context "Updating an annotation" do

      it "AS AUTHOR: should not be able to delete own annotations" do
        user = create(:user)
        paper = create(:paper, :submitted, submittor:user)
        annotation = create(:annotation, user: user, paper: paper)

        ability = Ability.new(user, paper, annotation)
        assert ability.cannot?(:destroy, annotation)
      end

      it "AS EDITOR: should be possible to delete annotations" do
        editor = create(:editor)
        user = create(:user)
        paper = create(:paper, submittor:user, editor:editor)
        annotation = create(:annotation, paper:paper)

        ability = Ability.new(editor, paper, annotation)
        assert ability.can?(:destroy, annotation)
      end

    end

    context "Changing the state of an annotation" do

      it "should be possible to dispute your own annotations" do
        user       = create(:user)
        paper      = create(:paper, submittor:user)
        annotation = build(:annotation, paper:paper, user:user)

        ability = Ability.new(user, paper)
        assert ability.can?(:dispute, annotation)
      end

      it "should be possible to resolve your own annotations" do
        user       = create(:user)
        paper      = create(:paper, submittor:user)
        annotation = build(:annotation, paper:paper, user:user)

        ability = Ability.new(user, paper)
        assert ability.can?(:resolve, annotation)
      end

      it "should be possible to unresolve your own annotations" do
        user       = create(:user)
        paper      = create(:paper, submittor:user)
        annotation = build(:annotation, paper:paper, user:user)

        ability = Ability.new(user, paper)
        assert ability.can?(:unresolve, annotation)
      end

      it "should not be possible to dispute annotations that are not your own" do
        user = create(:user)
        paper = create(:paper, :submitted, submittor:user)
        annotation = create(:annotation, user:create(:user), paper:paper)

        ability = Ability.new(user, paper, annotation)
        assert ability.cannot?(:dispute, annotation)
      end

      it "should not be possible to resolve annotations that are not your own" do
        user = create(:user)
        paper = create(:paper, :submitted, submittor:user)
        annotation = create(:annotation, user:create(:user), paper:paper)

        ability = Ability.new(user, paper, annotation)
        assert ability.cannot?(:resolve, annotation)
      end

      it "should not be possible to unresolve annotations that are not your own" do
        user = create(:user)
        paper = create(:paper, :submitted, submittor:user)
        annotation = create(:annotation, user:create(:user), paper:paper)

        ability = Ability.new(user, paper, annotation)
        assert ability.cannot?(:unresolve, annotation)
      end

      it "WITHOUT ROLE: should not be possible to dispute annotations on someone else's paper" do
        user = create(:user)
        paper = create(:paper) # note user doesn't own paper
        ability = Ability.new(user, paper)
        annotation = create(:annotation, paper: paper)

        assert ability.cannot?(:dispute, annotation)
      end

      it "WITHOUT ROLE: should not be possible to resolve annotations on someone else's paper" do
        user = create(:user)
        paper = create(:paper) # note user doesn't own paper
        ability = Ability.new(user, paper)
        annotation = create(:annotation, paper: paper)

        assert ability.cannot?(:resolve, annotation)
      end

      it "WITHOUT ROLE: should not be possible to unresolve annotations on someone else's paper" do
        user = create(:user)
        paper = create(:paper) # note user doesn't own paper
        ability = Ability.new(user, paper)
        annotation = create(:annotation, paper: paper)

        assert ability.cannot?(:unresolve, annotation)
      end

      it "AS EDITOR: should be possible to dispute annotation on paper" do
        editor = create(:editor)
        user = create(:user)
        paper = create(:paper, submittor:user, editor: editor)
        annotation = create(:annotation, paper: paper)

        ability = Ability.new(editor, paper, annotation)
        assert ability.can?(:dispute, annotation)
      end

      it "AS EDITOR: should be possible to resolve annotation on paper" do
        editor = create(:editor)
        user = create(:user)
        paper = create(:paper, submittor:user, editor: editor)
        annotation = create(:annotation, paper:paper)

        ability = Ability.new(editor, paper, annotation)
        assert ability.can?(:resolve, annotation)
      end

      it "AS EDITOR: should be possible to unresolve annotation on paper" do
        editor = create(:editor)
        user = create(:user)
        paper = create(:paper, submittor:user, editor:editor)
        annotation = create(:annotation, paper:paper)

        ability = Ability.new(editor, paper, annotation)
        assert ability.can?(:unresolve, annotation)
      end

    end

  end

  describe 'Validation' do

    it "should validate if the parent is nil" do
      paper = create(:paper)
      annotation1 = Annotation.new(paper:paper, body:'Issue 1', assignment:paper.assignments.first)

      expect(annotation1).to be_valid
    end

    it "should validate if the parent has the same paper" do
      paper = create(:paper)
      annotation1 = Annotation.create!(paper:paper, body:'Issue 1', assignment:paper.assignments.first)
      annotation2 = Annotation.new(paper:paper, body:'Issue 1', parent:annotation1, assignment:paper.assignments.first)

      expect(annotation2).to be_valid
    end

    it "should not validate if the assignee is not from the same paper" do
      assignment = create(:assignment)
      paper = create(:paper)
      annotation = Annotation.new(paper:paper, body:'Issue 1', assignment:assignment)

      expect(annotation).to be_invalid
    end

    it "should not validate if the parent annotation is from a different paper" do
      paper1 = create(:paper)
      annotation1 = Annotation.create!(paper:paper1, body:'Issue 1', assignment:paper1.assignments.first)
      paper2 = create(:paper)
      annotation2 = Annotation.new(paper:paper2, body:'Issue 1', parent:annotation1, assignment:paper2.assignments.first)

      expect(annotation2).to be_invalid
    end

  end

end
