class Deck
  RANKS = ["2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"]
  SUITS = ["S", "H", "C", "D"]
  CARDS = RANKS.each_with_object([]) do |rank, arr|
    SUITS.each { |suit| arr << (rank + suit) }
  end

  def self.shuffle
    CARDS.shuffle
  end
end
