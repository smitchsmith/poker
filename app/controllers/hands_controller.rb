class HandsController < ApplicationController
  before_action :find_hand, only: :show
  before_action :redirect_if_not_part_of_table, only: :show

  def show
    @current_player_hand = @hand.player_hands.find_by(player_id: current_user.id)
  end

  def update
    hand = Hand.find(params[:id])
    hand.next!(player: current_user, params: params)
    HandChannel.broadcast_to(hand, hand.id)
    redirect_to hand_path(hand.id)
  end

  private

  def find_hand
    @hand = Hand.find(params[:id])
  end

  def redirect_if_not_part_of_table
    if @hand.table.players.exclude?(current_user)
      redirect_to :root
    end
  end
end
