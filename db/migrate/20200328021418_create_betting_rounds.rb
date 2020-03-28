class CreateBettingRounds < ActiveRecord::Migration[6.0]
  def change
    create_table :betting_rounds do |t|
      t.integer :hand_id
      t.integer :initial_bet_id
      t.integer :amount
      t.integer :hand_round

      t.string  :kind

      t.timestamps
    end
  end
end
