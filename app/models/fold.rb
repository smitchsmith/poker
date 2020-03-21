class Fold < ApplicationRecord
  belongs_to :player, class_name: "User"
  belongs_to :hand
end
