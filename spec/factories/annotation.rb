FactoryGirl.define do
  factory :annotation do
    body           "You know, this really isn't good enough"
    created_at     { Time.now }
    updated_at     { Time.now }

    ignore do
      user     nil
      paper    nil
      parent   nil
      state    nil
    end

    factory :root, aliases:[:issue]

    factory :response do
      after(:build)   do |a, factory| a.parent ||= factory.association(:root, paper:a.paper) end
    end

    trait :unresolved do
      state :unresolved
    end
    trait :resolved do
      state :resolved
    end
    trait :disputed do
      state :disputed
    end

    after(:build) do |a, factory|
      if factory.paper
        a.paper = factory.paper
      elsif factory.parent
        a.paper = factory.parent.paper
      else
        a.paper = factory.association(:paper)
      end

      case factory.state
        when :unresolved then a.unresolve
        when :resolved   then a.resolve
        when :disputed   then a.dispute
      end

      # Do this after setting the state
      a.parent = factory.parent

      if factory.user
        assignment = a.paper.assignments.detect { |pa| pa.user == factory.user } if a.paper
        a.assignment = assignment || factory.association(:assignment, :collaborator, paper:a.paper, user:factory.user)

      elsif a.paper
        a.assignment = a.paper.assignments.last

      else
        user = create(:user)
        a.assignment = factory.association(:assignment, :collaborator, paper:a.paper, user:user)

      end

    end

    before(:create) do |a, factory|
      if factory.user
        a.paper.assignments.reload
      end
    end

  end
end
