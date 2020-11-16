# frozen_string_literal: true

FactoryBot.define do
  sequence(:email) {|n| "user#{n}@mail.com"}

  factory :user do
    email
    membership_type

    password              { '111111' }
    password_confirmation { '111111' }

    invite_status { :not_invited }    


    factory :user_with_entry do
      transient do
        made_at { Time.now }
      end

      after(:create) do |user, evaluator|
        time = evaluator.made_at
        create(:entry, user: user, created_at: time, entry_date: time)
      end
    end

    factory :user_with_family_member do
    end

    factory :family_member do
      family_subscriber factory: :user
    end
  end

  
end
