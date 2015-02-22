FactoryGirl.define do
  factory :annotation do
    user
    paper
    category       "important"
    body           "You know, this really isn't good enough"
    created_at     { Time.now }
    updated_at     { Time.now }

    trait :unresolved do
      after(:build) do |a| a.unresolve! end
    end
    trait :resolved do
      after(:build) do |a| a.resolve! end
    end
    trait :disputed do
      after(:build) do |a| a.dispute! end
    end

    after(:build) do |a|
      a.paper = a.parent.paper if a.parent && !a.paper
    end

    factory :root, aliases:[:issue]

    factory :reply do
      association :parent, factory: :root
    end

  end
end
