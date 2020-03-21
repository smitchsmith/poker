# cards

class Hand < ApplicationRecord
  belongs_to :table
  belongs_to :dealer, class_name: "User"
  has_many :player_hands

  delegate :name, to: :table, prefix: true
  delegate :players, :small_blind_amount, :big_blind_amount, to: :table

  def small_blind_player
    @small_blind_player ||= begin
      player_index = (players.index(dealer) + 1) % players.count
      players[player_index]
    end
  end

  def big_blind_player
    @big_blind_player ||= begin
      player_index = (players.index(dealer) + 2) % players.count
      players[player_index]
    end
  end
end
