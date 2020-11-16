# frozen_string_literal: true

FactoryBot.define do
  factory :entry do
    title { 'title' }
    description { 'description' }
    favorite { 1 }
    user
    entry_date { Date.today }
  end
end
