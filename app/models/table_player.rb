# balance

class TablePlayer < ApplicationRecord
  belongs_to :player, class_name: "User"
  belongs_to :table

  delegate :name, to: :table, prefix: true
  delegate :name, to: :player, prefix: true

  def not_in_hand?
    sitting_out? || balance.zero?
  end
end
