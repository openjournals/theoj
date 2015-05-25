class Annotation < ActiveRecord::Base
  include AASM

  belongs_to :paper,      inverse_of: :annotations
  belongs_to :assignment, inverse_of: :annotations

  has_many   :responses, class_name:'Annotation', foreign_key:'parent_id'
  belongs_to :parent,    class_name:'Annotation', foreign_key:'parent_id'

  scope :root_annotations , -> { where(parent_id: nil) }

  after_save :push_to_firebase

  validates_presence_of :body, :paper_id

  aasm column: :state, no_direct_assignment:true do
    state :unresolved,       initial:true
    state :resolved
    state :disputed

    event :unresolve, guard: :can_change_state? do
      transitions to: :unresolved
    end

    event :resolve, guard: :can_change_state? do
      transitions to: :resolved
    end

    event :dispute, guard: :can_change_state? do
      transitions to: :disputed
    end

  end

  def base_annotation
    parent_id.nil? ? self : parent
  end

  def firebase_key
    "/papers/#{paper.sha}/annotations/#{base_annotation.id}"
  end

  def push_to_firebase
    # Note this must be anonymized user data
    FirebaseClient.set firebase_key, AnnotationSerializer.new(base_annotation).as_json
  end

  def is_issue?
    parent_id.nil?
  end

  def has_responses?
    responses.any?
  end

  private

  def can_change_state?
    is_issue? && paper && paper.under_review?
  end

end
