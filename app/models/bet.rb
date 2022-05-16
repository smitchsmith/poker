# amount, kind, betting_round, player

class Bet < ApplicationRecord
  validate :player_has_funds, on: :create
  after_create :deduct_from_player

  belongs_to :betting_round
  belongs_to :player, class_name: "User"

  delegate :hand, :hand_id, to: :betting_round
  delegate :table, :table_id, to: :hand

  private

  def table_player
    @table_player ||= table.table_players.detect { |table_player| table_player.player == player }
  end

  def deduct_from_player
    table_player.update!(balance: table_player.balance - amount)
    update!(kind: "all_in") if table_player.balance.zero?
  end

  def player_has_funds
    if table_player.balance < amount
      errors.add(:player_balance, "is insufficient")
    end
  end
end
