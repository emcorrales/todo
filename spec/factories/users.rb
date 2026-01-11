require 'securerandom'

FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "user-#{SecureRandom.hex(4)}-#{n}" }
    password { "password" }
  end
end
