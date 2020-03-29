# cards, folded?

class PlayerHand < ApplicationRecord
  belongs_to :hand
  belongs_to :player, class_name: "User"

  delegate :balance, to: :table_player
  delegate :name, to: :player, prefix: true
  delegate :current_betting_round, to: :hand

  def call_amount
    amount = hand.current_player_bet - bets_sum
    balance > amount ? amount : balance
  end

  def calling_brings_all_in?
    call_amount == balance
  end

  def bets_sum
    bets.pluck(:amount).sum
  end

  def current_round_bets_sum
    bets.joins(:betting_round).where(betting_rounds: {hand_round: hand.round}).pluck(:amount).sum
  end

  def current_actor?
    hand.current_actor == player
  end

  def current_bettor?
    return false if hand.current_bettor.blank?
    hand.current_bettor == player
  end

  def result
    "#{best_poker_hand.rank} (#{cards.join(", ")})"
  end

  def final_status
    if hand.winners.include?(player)
      if hand.one_unfolded_player?
        "Won ¢#{hand.winners_with_amounts[player]}"
      else
        "Won ¢#{hand.winners_with_amounts[player]}\n#{result}"
      end
    else
      if folded?
        "Folded"
      else
        result
      end
    end
  end

  def status
    if hand.finished?
      final_status
    else
      if all_in?
        "All In"
      elsif folded?
        "Folded"
      elsif current_actor?
        "..."
      elsif current_bettor?
        if hand.betting_rounds.where(hand_round: hand.round).count == 1
          "Bet ¢#{current_betting_round.amount}" unless current_betting_round.try(:blinds?)
        else
          "Raised to ¢#{current_betting_round.amount}"
        end
      elsif has_acted?
        if current_betting_round.present?
          "Called"
        else
          "Checked"
        end
      end
    end
  end

  def name_with_position
    position = if dealer?
      "D"
    elsif small_blind?
      "SB"
    elsif big_blind?
      "BB"
    end

    position.present? ? "#{player_name} (#{position})" : player_name
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

  def best_poker_hand
    @best_poker_hand ||= (cards + hand.cards).combination(5).map do |combination|
      PokerHand.new(combination)
    end.sort.last
  end

  def bring_to_all_in_amount
    current_round_bets_sum + balance
  end

  def all_in?
    all_in_bet.present?
  end

  def all_in_bet
    bets.where(kind: "all_in").first
  end

  private

  def bets
    Bet.joins(:betting_round).where(player_id: player_id, betting_rounds: {hand_id: hand_id})
  end

  def table_player
    TablePlayer.find_by(table_id: hand.table_id, player_id: player_id)
  end
end
