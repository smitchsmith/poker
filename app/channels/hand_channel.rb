class HandChannel < ApplicationCable::Channel
  def subscribed
    hand = Hand.find(params[:id])
    stream_for hand
  end
end
