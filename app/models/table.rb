class Table < ApplicationRecord
  SMALL_BLIND = 10
  BIG_BLIND   = SMALL_BLIND * 2

  has_many :table_players
  has_many :all_players, through: :table_players, source: :player
  has_many :hands

  def create_hand!
    ActiveRecord::Base.transaction do
      cards      = Deck.shuffle
      hand_cards = cards.shift(5)
      hand       = hands.create!(cards: hand_cards, dealer: next_dealer)
      hand.setup!(cards)
    end
  end

  def distribute_pot!(winners:, pot:)
    winning_table_players = table_players.select { |table_player| winners.include?(table_player.player) }
    winning_pot_amount    = pot / winners.count
    winning_table_players.each do |table_player|
      table_player.update(balance: table_player.balance + winning_pot_amount)
    end
  end

  def small_blind_amount
    SMALL_BLIND
  end

  def big_blind_amount
    BIG_BLIND
  end

  def players
    all_players.order(:id)
  end

  private

  def next_dealer
    return players.first if current_dealer.blank?
    current_hand.small_blind_player
  end

  def current_dealer
    current_hand.try(:dealer)
  end

  def current_hand
    hands.order(:id).last
  end
end
