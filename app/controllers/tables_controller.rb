class TablesController < ApplicationController
  def deal_cards
    table        = Table.find(params[:id])
    current_hand = table.current_hand
    new_hand     = table.create_hand!
    HandChannel.broadcast_to(current_hand, new_hand.id) if table.current_hand.present?
    redirect_to hand_path(new_hand.id)
  end
end
