# balance

class TablePlayer < ApplicationRecord
  belongs_to :player, class_name: "User"
  belongs_to :table
end
