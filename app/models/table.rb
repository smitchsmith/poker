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

  def distribute_pot!(winners_with_amounts)
    winners_with_amounts.each do |player, amount|
      table_player = table_players.detect { |table_player| table_player.player == player }
      table_player.update!(balance: table_player.balance + amount)
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

  def current_hand
    hands.order(:id).last
  end

  private

  def next_dealer
    if current_hand.present?
      current_hand.small_blind_player
    else
      players.first
    end
  end
end
