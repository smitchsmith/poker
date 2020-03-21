class HandsController < ApplicationController
  def show
    @hand = Hand.find(params[:id])
    @current_player_hand = @hand.player_hands.find_by(player_id: current_user.id)
  end
end
