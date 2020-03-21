# cards

class PlayerHand < ApplicationRecord
  belongs_to :hand
  belongs_to :player, class_name: "User"

  delegate :name, to: :player, prefix: true

  def result
    # best_poker_hand
    "#{best_poker_hand.rank} (#{best_poker_hand.cards})"
  end

  def best_cards
    best_poker_hand.cards.split(" ")
  end

  def hand_status
    if dealer?
      "Dealer"
    elsif small_blind?
      "Small Blind"
    elsif big_blind?
      "Big Blind"
    end
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
    @player_balance ||= TablePlayer.find_by(table_id: hand.table_id, player_id: player_id).balance
  end

  # private

  def best_poker_hand
    @best_poker_hand ||= (cards + hand.cards).combination(5).map do |combination|
      PokerHand.new(combination)
    end.sort.last
  end
end
