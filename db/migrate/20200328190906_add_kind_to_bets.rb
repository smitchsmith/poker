class AddKindToBets < ActiveRecord::Migration[6.0]
  def change
    add_column :bets, :kind, :string
  end
end
