class CreateBets < ActiveRecord::Migration[6.0]
  def change
    create_table :bets do |t|
      t.integer :hand_id
      t.integer :player_id
      t.integer :amount

      t.timestamps
    end
  end
end
