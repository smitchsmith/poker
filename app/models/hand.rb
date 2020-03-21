# cards, current_actor, current_bet, round

class Hand < ApplicationRecord
  VISIBLE_CARDS = [0, 3, 4, 5]

  belongs_to :table
  belongs_to :dealer, class_name: "User"
  belongs_to :current_actor, class_name: "User", optional: true
  belongs_to :current_bet, class_name: "Bet", optional: true
  has_many :player_hands
  has_many :bets

  delegate :name, to: :table, prefix: true
  delegate :players, :small_blind_amount, :big_blind_amount, to: :table
  delegate :amount, to: :current_bet, prefix: true, allow_nil: true

  def setup!(cards)
    ActiveRecord::Base.transaction do
      players.each do |player|
        player_hands.create!(player: player, cards: cards.shift(2))
      end

      bets.create!(player: small_blind_player, amount: small_blind_amount)
      big_blind_bet = bets.create!(player: big_blind_player, amount: big_blind_amount)
      update!(current_actor: relative_player(3), current_bet: big_blind_bet)
      self
    end
  end

  def current_pot
    bets.pluck(:amount).sum
  end

  def current_player_bet
    player_hands.each_with_object({}) do |player_hand, h|
      h[player_hand.player_id] ||= 0
      h[player_hand.player_id] += player_hand.bets_sum
    end.values.max
  end

  def minimum_raise
    big_blind_amount + current_bet.try(:amount).to_i
  end

  def minimum_bet
    big_blind_amount
  end

  def finished?
    round == 4
  end

  def next_hand_dealt?
    next_hand.present?
  end

  def next_hand
    table.hands.where("hands.id > ?", id).order(:id).first
  end

  def next!(player:, params:)
    ActiveRecord::Base.transaction do
      HandAction.act!(player: player, hand: self, params: params)

      if next_round?
        if remaining_players.count == 1 || round + 1 > 3
          table.distribute_pot!(winners: winners, pot: current_pot)
          update!(round: 4, current_actor: nil, current_bet: nil)
        else
          update!(round: round + 1, current_actor: remaining_first_player, current_bet: nil)
        end
      else
        update!(current_actor: next_player)
      end
    end
  end

  def next_round?
    next_player.blank? || remaining_players.count == 1
  end

  def visible_cards
    if round < 3
      cards[0...VISIBLE_CARDS[round]]
    else
      cards
    end
  end

  def winners
    best_poker_hand = remaining_player_hands.map(&:best_poker_hand).sort.last
    remaining_player_hands.select { |player_hand| player_hand.best_poker_hand == best_poker_hand }.map(&:player)
  end

  def remaining_player_hands
    player_hands.select { |player_hand| remaining_players.include?(player_hand.player) }
  end

  def acted_players
    actor_index = bettor_relative_players.index(current_actor)
    bettor_relative_players[0...actor_index] - folded_players
  end

  def folded_players
    player_hands.select(&:folded?).map(&:player)
  end

  def current_bettor
    current_bet.try(:player)
  end

  def remaining_first_player
    (remaining_players - [dealer]).first
  end

  def next_player
    next_player = (bettor_relative_players - folded_players - acted_players - [current_actor]).first

    if round.zero? && bets.where(player_id: big_blind_player).count == 1
      if current_actor == big_blind_player
        nil
      elsif next_player.blank?
        big_blind_player
      else
        next_player
      end
    else
      next_player
    end
  end

  def relative_player(relative_position)
    remaining_players[relative_position % players.count]
  end

  def remaining_players
    dealer_relative_players - folded_players
  end

  def bettor_relative_players
    return small_blind_relative_players if current_bettor.blank?

    @bettor_relative_players ||= players.to_a.dup.tap do |relative_players|
      until relative_players.first == current_bettor
        relative_players.push relative_players.shift
      end
    end
  end

  def small_blind_relative_players
    @small_blind_relative_players ||= players.to_a.dup.tap do |relative_players|
      until relative_players.first == small_blind_player
        relative_players.push relative_players.shift
      end
    end
  end

  def dealer_relative_players
    @dealer_relative_players ||= players.to_a.dup.tap do |relative_players|
      until relative_players.first == dealer
        relative_players.push relative_players.shift
      end
    end
  end

  def small_blind_player
    @small_blind_player ||= begin
      if players.count == 2
        dealer
      else
        relative_player(1)
      end
    end
  end

  def big_blind_player
    @big_blind_player ||= begin
      if players.count == 2
        relative_player(1)
      else
        relative_player(2)
      end
    end
  end
end
