class Table < ApplicationRecord
  SMALL_BLIND = 10
  BIG_BLIND   = SMALL_BLIND * 2

  has_many :table_players
  has_many :all_players, through: :table_players, source: :player
  has_many :hands

  def create_hand!
    cards      = Deck.shuffle
    hand_cards = cards.shift(5)
    hand       = hands.create!(cards: hand_cards, dealer: next_dealer)
    players.each do |player|
      hand.player_hands.create!(player: player, cards: cards.shift(2))
    end

    # handle blinds
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
