class TablesController < ApplicationController
  def deal_cards
    table  = Table.find(params[:id])
    hand   = table.create_hand!
    redirect_to hand_path(hand.id)
  end
end
