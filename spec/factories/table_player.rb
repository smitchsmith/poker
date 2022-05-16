FactoryBot.define do
  factory :table_player do
    association(:player)
    balance { 1000 }
  end
end
