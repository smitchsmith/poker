class ChangeHandsToCurrentBettingRound < ActiveRecord::Migration[6.0]
  def change
    remove_column :hands, :current_bet_id, :integer
    add_column    :hands, :current_betting_round_id, :integer
  end
end
