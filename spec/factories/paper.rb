FactoryGirl.define do
  factory :paper do
    location       "http://example.com/1234"
    state          "submitted"
    title          "My awesome paper"
    summary        "Summary of my awesome paper"
    sha            "1234abcd" * 8
    author_list    "John Smith, Paul Adams, Ella Fitzgerald"
    user

    submitted_at   { Time.now }
    version        1
    created_at     { Time.now }
    updated_at     { Time.now }

    trait :submitted do state 'submitted' end
    factory :submitted_paper do
      submitted
    end

    trait :under_review do state 'under_review' end
    factory :paper_under_review do
      under_review
    end

    trait :accepted do state 'accepted' end
    factory :accepted_paper do
      accepted
    end

    ignore do
      reviewer nil
    end
    after(:create) do |paper, factory|
      if factory.reviewer
        reviewer = factory.reviewer == true ? create(:user) : factory.reviewer
        create(:assignment_as_reviewer, user:reviewer, paper:paper)
      end
    end

  end
end
