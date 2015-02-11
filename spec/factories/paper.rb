FactoryGirl.define do
  factory :paper do
    location       "http://example.com/1234"
    state          "pending"
    title          "My awesome paper"
    summary        "Summary of my awesome paper"
    sha            "1234abcd" * 8
    author_list    "John Smith, Paul Adams, Ella Fitzgerald"
    user

    submitted_at   { Time.now }
    version        1
    created_at     { Time.now }
    updated_at     { Time.now }

    factory :submitted_paper do
      state "submitted"
    end

    factory :paper_under_review do
      state "under_review"
    end

    factory :accepted_paper do
      state "accepted"
    end
  end
end
