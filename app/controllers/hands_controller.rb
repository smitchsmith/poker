class HandsController < ApplicationController
  def show
    @hand = Hand.find(params[:id])
    @current_player_hand = @hand.player_hands.find_by(player_id: current_user.id)
  end

  def update
    hand = Hand.find(params[:id])
    hand.next!(player: current_user, params: params)
    HandChannel.broadcast_to(hand, "update")
    redirect_to hand_path(hand.id)
  end
end
