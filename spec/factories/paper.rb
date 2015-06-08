FactoryGirl.define do
  factory :paper do
    location       "http://example.com/1234"
    state          "submitted"
    title          "My awesome paper"
    summary        "Summary of my awesome paper"
    # sha          "1234abcd" * 8
    author_list    "John Smith, Paul Adams, Ella Fitzgerald"
    association    :submittor, factory: :user
    version        1
    created_at     { Time.now }
    updated_at     { Time.now }

    Paper.aasm.states.each do |s|
      trait s.name do state s.name end
    end

    ignore do
      reviewer     nil
      collaborator nil
    end

    after(:build) do |paper, factory|
      paper.send(:create_assignments) if paper.submittor

      if factory.reviewer
        reviewers = Array(factory.reviewer==true ? create(:user) : factory.reviewer)
        reviewers.each do |r|
          paper.assignments.build(role: :reviewer, user:r)
        end
      end

      if factory.collaborator
        collaborators = Array(factory.collaborator==true ? create(:user) : factory.collaborator)
        collaborators.each do |c|
          paper.assignments.build(role: :collaborator, user:c)
        end
      end

    end

  end
end
