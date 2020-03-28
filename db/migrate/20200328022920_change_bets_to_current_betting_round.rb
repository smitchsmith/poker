class ChangeBetsToCurrentBettingRound < ActiveRecord::Migration[6.0]
  def change
    remove_column :bets, :hand_id, :integer
    add_column :bets, :betting_round_id, :integer
  end
end
