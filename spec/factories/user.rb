FactoryBot.define do
  factory :player, class: User do # TODO fix this
    sequence(:email) { |n| "test_email_#{n}@example.com" }
    sequence(:name) { |n| "Test User#{n}"}
    password { "123456" }
  end
end
