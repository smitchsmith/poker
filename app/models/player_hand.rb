# cards, folded?

class PlayerHand < ApplicationRecord
  belongs_to :hand
  belongs_to :player, class_name: "User"

  delegate :balance, to: :table_player
  delegate :name, to: :player, prefix: true

  def call_amount
    hand.current_player_bet - bets_sum
  end

  def bets_sum
    bets.pluck(:amount).sum
  end

  def current_actor?
    hand.current_actor == player
  end

  def current_bettor?
    return false if hand.current_bettor.blank?
    hand.current_bettor == player
  end

  def result
    "#{best_poker_hand.rank} (#{best_poker_hand.cards})"
  end

  def status
    if hand.finished?
      "Winner: #{result}" if hand.winners.include?(player)
    else
      if folded?
        "Folded"
      elsif current_actor?
        "..."
      elsif current_bettor?
        "Bet #{hand.current_bet.amount}"
      elsif has_acted?
        if hand.current_bet.present?
          "Called"
        else
          "Checked"
        end
      end
    end
  end

  def position
    if dealer?
      "Dealer"
    elsif small_blind?
      "Small Blind"
    elsif big_blind?
      "Big Blind"
    end
  end

  def has_acted?
    hand.acted_players.include?(player)
  end

  def dealer?
    hand.dealer == player
  end

  def small_blind?
    hand.small_blind_player == player
  end

  def big_blind?
    hand.big_blind_player == player
  end

  def player_balance
    @player_balance ||= table_player.balance
  end

  def best_poker_hand
    @best_poker_hand ||= (cards + hand.cards).combination(5).map do |combination|
      PokerHand.new(combination)
    end.sort.last
  end

  private

  def bets
    Bet.where(hand_id: hand_id, player_id: player_id)
  end

  def table_player
    TablePlayer.find_by(table_id: hand.table_id, player_id: player_id)
  end
end
