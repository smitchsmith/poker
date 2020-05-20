class TablesController < ApplicationController
  before_action :find_table, only: [:edit, :update, :deal_cards, :deal_first_hand]

  def new
    @table = Table.new
    @table.table_players.build
  end

  def create
    @table = Table.create(table_params.merge(created_by: current_user))
    if @table.persisted?
      redirect_to root_path(@table)
    else
      render :new
    end
  end

  def edit; end

  def update
    if @table.update_attributes(table_params)
      redirect_to root_path(@table)
    else
      render :edit
    end
  end

  def deal_cards
    current_hand = @table.current_hand
    new_hand     = @table.create_hand!
    HandChannel.broadcast_to(current_hand, new_hand.id) if @table.current_hand.present?
    redirect_to hand_path(new_hand.id)
  end

  def deal_first_hand
    if @table.hands.present?
      redirect_to hand_path(@table.current_hand)
    else
      deal_cards
    end
  end

  private

  def find_table
    @table = Table.find(params[:id])
  end

  def table_params
    params.require(:table).permit(:name, :big_blind_amount, :small_blind_amount, :starting_balance, :active, table_players_attributes: [:id, :player_id, :balance])
  end
end
