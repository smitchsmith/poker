class PotSplitter < Struct.new(:player_hands, :amount)
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
      sorted_player_hands = player_hands.sort_by(&:bets_sum)
      previous_player_hand = nil
      until subpots.map(&:amount).sum == amount
        if sorted_player_hands.map(&:bets_sum).uniq.count == 1
          total_amount_remaining = amount - subpots.map(&:amount).sum
          subpots << Pot.new(sorted_player_hands, total_amount_remaining)
        else
          pot_player_hands     = sorted_player_hands.dup
          current_player_hand  = sorted_player_hands.shift
          folded_bets_amount   = folded_bets_map[current_player_hand.all_in_bet].to_i
          pot_amount           = ((current_player_hand.bets_sum - previous_player_hand.try(:bets_sum).to_i) * pot_player_hands.count) + folded_bets_amount
          previous_player_hand = current_player_hand
          subpots << Pot.new(pot_player_hands, pot_amount)
        end
      end
    end
  end

  def folded_bets_map
    @folded_bets_map ||= begin
      all_in_bets    = player_hands.flat_map(&:all_in_bet).compact.sort_by(&:id)
      all_in_bet_ids = all_in_bets.map(&:id)
      all_in_bets.each_with_object({}).with_index do |(bet, h), i|
        previous_id = i == 0 ? 1 : all_in_bet_ids[i - 1]
        folded_bets = hand.bets.where(id: previous_id..bet.id, player_id: hand.folded_players.map(&:id))
        h[bet] = folded_bets.map(&:amount).sum
      end
    end
  end

  def hand
    @hand ||= player_hands.first.hand
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
