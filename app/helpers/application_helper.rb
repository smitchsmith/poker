module ApplicationHelper
  SUITS = {
    "S" => {symbol: "♠", color: "black"},
    "C" => {symbol: "♣", color: "black"},
    "H" => {symbol: "♥", color: "red"},
    "D" => {symbol: "♦", color: "red"}
  }

  def humanize_cards(cards)
    cards.sort_by do |card|
      Card::FACES.index(card.first)
    end.map do |card|
      rank, suit = card.split("")
      suit_data  = SUITS[suit]
      "<span class='small-card-#{suit_data[:color]}'>#{rank}#{suit_data[:symbol]}</span>"
    end.join("&nbsp;").html_safe
  end
end
