# cards, round, table, dealer, current_actor, current_betting_round

class Hand < ApplicationRecord
  VISIBLE_CARDS = [0, 3, 4, 5]

  belongs_to :table
  belongs_to :dealer, class_name: "User"
  belongs_to :current_actor, class_name: "User", optional: true
  belongs_to :current_betting_round, class_name: "BettingRound", optional: true
  has_many :player_hands
  has_many :betting_rounds
  has_many :bets, through: :betting_rounds

  delegate :name, to: :table, prefix: true
  delegate :players, :table_players, :small_blind_amount, :big_blind_amount, to: :table
  alias :minimum_bet :big_blind_amount

  def setup!(cards)
    ActiveRecord::Base.transaction do
      table_players.each do |table_player|
        next if table_player.balance.zero?
        player_hands.create!(player: table_player.player, cards: cards.shift(2))
      end

      betting_round = create_betting_round!(player: big_blind_player, amount: big_blind_amount, kind: "blinds")
      betting_round.create_bet!(player: small_blind_player, amount: small_blind_amount)
      update!(current_actor: relative_player(3))
      self
    end
  end

  def next!(player:, params:)
    ActiveRecord::Base.transaction do
      HandAction.act!(player: player, hand: self, params: params)

      if next_round?
        if betting_finished? || round + 1 > 3
          table.distribute_pot!(winners_with_amounts)
          update!(round: 4, current_actor: nil, current_betting_round: nil)
        else
          update!(round: round + 1, current_actor: first_actor, current_betting_round: nil)
        end
      else
        update!(current_actor: next_player)
      end
    end
  end

  def create_betting_round!(player:, amount:, kind: nil)
    betting_round = betting_rounds.create!(kind: kind, hand_round: round, amount: amount)
    player_hand   = player_hands.find_by(player_id: player.id)
    bet_amount    = amount - player_hand.current_round_bets_sum
    betting_round.initial_bet = betting_round.create_bet!(player: player, amount: bet_amount)
    betting_round.save!
    update!(current_betting_round: betting_round)
    return betting_round
  end

  def winners_with_amounts
    PotSplitter.new(remaining_player_hands, pot_amount).winners_with_amounts
  end

  def winners
    winners_with_amounts.keys
  end

  def finished?
    round == 4
  end

  def visible_cards
    if round < 3
      cards[0...VISIBLE_CARDS[round]]
    else
      cards
    end
  end

  def pot_amount
    bets.pluck(:amount).sum
  end

  def current_bet_amount
    current_betting_round.try(:amount).to_i
  end

  def current_bettor
    current_betting_round.try(:bettor)
  end

  def largest_bets_sum
    player_hands.map(&:bets_sum).max
  end

  def minimum_raise
    if current_betting_round.present?
      current_betting_round.amount + current_betting_round.amount_raised_by
    else
      minimum_bet
    end
  end

  def one_unfolded_player?
    remaining_players.count == 1
  end

  def acted_players
    actor_index = bettor_relative_players.index(current_actor)
    bettor_relative_players[0...actor_index] - folded_players
  end

  def remaining_players
    dealer_relative_players - folded_players
  end

  def folded_players
    player_hands.select(&:folded?).map(&:player)
  end

  def all_in_players
    player_hands.select(&:all_in?).map(&:player)
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

  def next_hand
    table.hands.where("hands.id > ?", id).order(:id).first
  end

  private

  def next_round?
    next_player.blank? || betting_finished?
  end

  def betting_finished?
    one_unfolded_player? || (((remaining_players - all_in_players).count <= 1) && next_player.blank?)
  end

  def first_actor
    (remaining_players - [dealer]).first
  end

  def next_player
    next_player = (bettor_relative_players - folded_players - acted_players - all_in_players - [current_actor]).first

    if current_betting_round.try(:blinds?)
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

  def remaining_player_hands
    player_hands.select { |player_hand| remaining_players.include?(player_hand.player) }
  end

  def relative_player(relative_position)
    dealer_relative_players[relative_position % players.count]
  end

  def bettor_relative_players
    @bettor_relative_players ||= players.to_a.dup.tap do |relative_players|
      until relative_players.first == (current_bettor || small_blind_player)
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
end
