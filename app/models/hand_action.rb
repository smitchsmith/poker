class HandAction < OpenStruct
  def self.act!(options)
    new(options).act!
  end

  def act!
    send(action)
  end

  private

  def fold
    player_hand.update!(folded: true)
  end

  def check
    # no-op
  end

  def call
    hand.bets.create!(player: player, amount: player_hand.call_amount)
  end

  def bet
    new_bet = hand.bets.create!(player: player, amount: bet_amount)
    hand.update!(current_bet: new_bet)
  end

  def raise_bet
    bet
  end

  def bet_amount
    params[:bet][:amount].to_i
  end

  def action
    params[:hand][:action]
  end

  def player_hand
    @player_hand ||= PlayerHand.find_by(hand_id: hand.id, player_id: player.id)
  end
end
