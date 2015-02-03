class Annotation < ActiveRecord::Base
  include AASM

  belongs_to :paper
  belongs_to :user

  has_many :responses, :class_name => "Annotation", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "Annotation", :foreign_key => "parent_id"

  scope :root_annotations , -> { where(parent_id: nil) }

  validates_presence_of :body, :paper_id

  aasm column: :state do
    state :new,          initial:true
    state :resolved
    state :challenged

    event :resolve do
      transitions to: :resolved
    end
  end

  def has_responses?
    responses.any?
  end
end
