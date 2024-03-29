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
    hand.current_betting_round.create_bet!(player: player, amount: player_hand.call_amount)
  end

  def bet
    if bet_amount == player_hand.call_amount
      call
    else
      hand.create_betting_round!(player: player, amount: bet_amount)
    end
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
    @player_hand ||= hand.player_hands.detect { |player_hand| player_hand.player == player }
  end
end
