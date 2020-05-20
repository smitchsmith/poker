# name, active?, big_blind_amount, small_blind_amount

class Table < ApplicationRecord
  belongs_to :created_by, class_name: "User", optional: true
  has_many :table_players
  has_many :all_players, through: :table_players, source: :player
  has_many :hands
  accepts_nested_attributes_for :table_players

  validates :name, :small_blind_amount, :big_blind_amount, presence: true

  def create_hand!
    raise if active_players.count < 2
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

  def players
    table_players.order(:id).map(&:player)
  end

  def player_names
    players.map(&:name)
  end

  def active_players
    table_players.reject(&:sitting_out?).sort_by(&:id).map(&:player)
  end

  def current_hand
    hands.order(:id).last
  end

  private

  def next_dealer
    if current_hand.present?
      next_dealer = nil
      i           = 1
      until next_dealer.present?
        relative_player = current_hand.relative_player(i)
        next_dealer     = relative_player if active_players.include?(relative_player)
        i += 1
      end
      next_dealer
    else
      active_players.first
    end
  end
end
