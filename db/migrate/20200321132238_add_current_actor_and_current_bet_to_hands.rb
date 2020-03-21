class AddCurrentActorAndCurrentBetToHands < ActiveRecord::Migration[6.0]
  def change
    add_column :hands, :current_actor_id, :integer
    add_column :hands, :current_bet_id, :integer
    add_column :hands, :round, :integer, default: 0
  end
end
