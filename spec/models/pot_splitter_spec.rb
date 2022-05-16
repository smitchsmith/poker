require 'rails_helper'

RSpec.describe PotSplitter, type: :model do
  describe "#winners_with_amounts - pot_split_table_1" do
    let(:table) { FactoryBot.create(:pot_split_table_1) }
    before do
      stacked_cards = [
        "2S", "3S", "4S", "5S", "5C", # hole cards
        "6S", "7S", # player 1 (balance 500) - straight flush
        "5H", "KH", # player 2 (balance 900) - three of a kind
        "4H", "QH", # player 3 (balance 1400) - two pair
        "TH", "JH"  # player 4 (balance 1800) - pair
      ]
      stacked_deck = stacked_cards | Deck::CARDS
      allow(Deck).to receive_messages(shuffle: stacked_deck)
      hand = table.create_hand!
      hand.player_hands.count.times do
        player = hand.current_actor
        player_hand = hand.player_hands.detect { |player_hand| player_hand.player == player }
        params = {hand: {action: :bet}, bet: {amount: player_hand.bring_to_all_in_amount}}
        hand.next!(player: player, params: params)
      end
    end

    it 'calculates correctly' do
      winner_amounts = [
        2000, # overall winner - all in amount (500) * 4
        1200, # 2nd winner     - (900 - 500) * 3
        1000, # 3rd winner     - (1400 - 900) * 2
        400   # loser          - (1800 - 1400)
      ]
      table.table_players.each_with_index do |table_player, i|
        expect(table.current_hand.winners_with_amounts[table_player.player]).to eq winner_amounts[i]
      end
    end
  end
end
