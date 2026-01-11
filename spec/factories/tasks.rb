FactoryBot.define do
  factory :task do
    sequence(:title) { |n| "Task #{n}" }
    description { "A task" }
    completed { false }
    sequence(:position) { |n| n }
    association :user
  end
end
