# hand, player, amount

class Bet < ApplicationRecord
  validate :player_has_funds
  after_create :deduct_from_player

  belongs_to :hand
  belongs_to :player, class_name: "User"

  private

  def table_player
    @table_player ||= TablePlayer.find_by(table_id: hand.table_id, player_id: player_id)
  end

  def deduct_from_player
    table_player.update!(balance: table_player.balance - amount)
  end

  def player_has_funds
    if table_player.balance < amount
      errors.add(:player_balance, "is insufficient")
    end
  end
end
