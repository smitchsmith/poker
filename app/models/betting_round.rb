# hand, kind

class BettingRound < ApplicationRecord
  belongs_to :initial_bet, class_name: "Bet", optional: true
  belongs_to :hand
  has_many :bets

  def create_bet!(bet_attributes)
    bets.create!(bet_attributes)
  end

  def bettor
    initial_bet.player
  end

  def blinds?
    kind == "blinds"
  end
end
