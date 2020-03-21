class AddFoldedToPlayerHands < ActiveRecord::Migration[6.0]
  def change
    add_column :player_hands, :folded, :boolean
  end
end
