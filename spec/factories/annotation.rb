FactoryGirl.define do
  factory :annotation do
    paper
    body           "You know, this really isn't good enough"
    created_at     { Time.now }
    updated_at     { Time.now }

    ignore do
      user     nil
    end

    trait :unresolved do
      after(:build) do |a| a.unresolve! end
    end
    trait :resolved do
      after(:build) do |a| a.resolve! end
    end
    trait :disputed do
      after(:build) do |a| a.dispute! end
    end

    after(:build) do |a, factory|
      a.paper = a.parent.paper if !a.paper && a.parent

      if factory.user
        assignment = a.paper.assignments.detect { |pa| pa.user == factory.user } if a.paper
        a.assignment = assignment || create(:assignment, :collaborator, user:factory.user)

      elsif a.paper
        a.assignment = a.paper.assignments.last

      else
        user = create(:user)
        a.assignment = create(:assignment, :collaborator, user:user)

      end

    end

    factory :root, aliases:[:issue]

    factory :reply do
      association :parent, factory: :root
    end

  end
end
