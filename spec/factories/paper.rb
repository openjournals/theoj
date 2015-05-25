FactoryGirl.define do
  factory :paper do
    location       "http://example.com/1234"
    state          "submitted"
    title          "My awesome paper"
    summary        "Summary of my awesome paper"
    sha            "1234abcd" * 8
    author_list    "John Smith, Paul Adams, Ella Fitzgerald"
    association    :submittor, factory: :user

    submitted_at   { Time.now }
    version        1
    created_at     { Time.now }
    updated_at     { Time.now }

    trait :submitted do state 'submitted' end

    trait :under_review do state 'under_review' end

    trait :accepted do state 'accepted' end

    ignore do
      reviewer     nil
      collaborator nil
    end

    after(:create) do |paper, factory|

      if factory.reviewer
        reviewers = Array(factory.reviewer)
        reviewers.each do |r|
          reviewer = r == true ? create(:user) : r
          create(:assignment, :reviewer, user:reviewer, paper:paper)
        end
      end

      if factory.collaborator
        collaborators = Array(factory.collaborator)
        collaborators.each do |c|
          collaborator = c == true ? create(:user) : c
          create(:assignment, :collaborator, user:collaborator, paper:paper)
        end
      end

    end

  end
end
