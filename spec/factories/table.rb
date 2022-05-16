FactoryBot.define do
  factory :table do
    name { "Test Table" }
    active { true }
    big_blind_amount { 20 }
    small_blind_amount { 10 }

    after(:create) do |table|
      table.table_players = 4.times.map { FactoryBot.create(:table_player, table_id: table.id) }
      table.created_by_id = table.table_players.first.id
      table.save!
    end
  end

  factory :pot_split_table_1, class: Table do
    name { "Pot Split 1" }
    active { true }
    big_blind_amount { 20 }
    small_blind_amount { 10 }

    after(:create) do |table|
      table.table_players = [500, 900, 1400, 1800].map do |balance|
        FactoryBot.create(:table_player, table_id: table.id, balance: balance)
      end
      table.created_by_id = table.table_players.first.id
      table.save!
    end
  end
end
