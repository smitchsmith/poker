class PotSplitter < Struct.new(:hand)
  delegate :remaining_player_hands, :folded_player_hands, to: :hand

  def winners_with_amounts
    subpots.each_with_object({}) do |pot, h|
      pot.winners_with_amounts.each do |winner, amount|
        h[winner] ||= 0
        h[winner] += amount
      end
    end
  end

  private

  def subpots
    @subpots ||= [].tap do |subpots|
      sorted_player_hands = remaining_player_hands.sort_by(&:bets_sum)
      previous_player_hand = nil
      until subpots.map(&:amount).sum == amount
        if sorted_player_hands.map(&:bets_sum).uniq.count == 1
          total_amount_remaining = amount - subpots.map(&:amount).sum
          subpots << Pot.new(sorted_player_hands, total_amount_remaining)
        else
          pot_player_hands     = sorted_player_hands.dup
          current_player_hand  = sorted_player_hands.shift
          current_amount       = current_player_hand.bets_sum
          previous_amount      = previous_player_hand.try(:bets_sum).to_i
          folded_bets_amount   = folded_bets_amount_for(previous_amount, current_amount)
          pot_amount           = ((current_amount - previous_amount) * pot_player_hands.count) + folded_bets_amount
          previous_player_hand = current_player_hand
          subpots << Pot.new(pot_player_hands, pot_amount) if pot_amount > 0
        end
      end
    end
  end

  def folded_bets_amount_for(range_min, range_max)
    folded_player_hands.map(&:bets_sum).map do |folded_bet_amount|
      if folded_bet_amount > range_min
        amount     = folded_bet_amount - range_min
        max_amount = range_max - range_min
        amount > max_amount ? max_amount : amount
      end
    end.compact.sum
  end

  def amount
    hand.pot_amount
  end

  class Pot < Struct.new(:player_hands, :amount)
    def winners_with_amounts
      winners.each_with_object({}) do |winner, h|
        h[winner] = winning_amount
      end
    end

    private

    def best_poker_hand
      @best_poker_hand ||= player_hands.map(&:best_poker_hand).sort.last
    end

    def winners
      player_hands.select { |player_hand| player_hand.best_poker_hand == best_poker_hand }.map(&:player)    
    end

    def winning_amount
      @winning_amount ||= amount / winners.count
    end
  end
end
