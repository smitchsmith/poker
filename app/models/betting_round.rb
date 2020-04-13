# kind, hand_round, amount, hand, initial_bet

class BettingRound < ApplicationRecord
  belongs_to :initial_bet, class_name: "Bet", optional: true
  belongs_to :hand
  has_many :bets

  def create_bet!(bet_attributes)
    bets.create!(bet_attributes)
  end

  def bettor
    if blinds?
      hand.under_the_gun_player
    else
      initial_bet.player
    end
  end

  def blinds?
    kind == "blinds"
  end

  def amount_raised_by
    amount - previous_round.try(:amount).to_i
  end

  def previous_round
    hand.betting_rounds.where(hand_round: hand_round).where("id < #{id}").last
  end
end
