FactoryGirl.define do
  factory :assignment do
    user
    paper
    role           'collaborator'
    created_at     { Time.now }
    updated_at     { Time.now }

    trait :collaborator do
      role 'collaborator'
    end

    trait :reviewer do
      role 'reviewer'
    end

    trait :editor do
      role 'editor'
    end

  end
end
