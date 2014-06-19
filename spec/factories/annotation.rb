FactoryGirl.define do
  factory :annotation do
    user
    paper
    state          "new"
    category       "important"
    body           "You know, this really isn't good enough"
    created_at     { Time.now }
    updated_at     { Time.now }

    factory :resolved_annotation do
      state "resolved"
    end

    factory :challenged_annotation do
      state "challenged"
    end
  end
end
