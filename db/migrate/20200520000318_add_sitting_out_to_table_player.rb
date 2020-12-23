class AddSittingOutToTablePlayer < ActiveRecord::Migration[6.0]
  def change
    add_column :table_players, :sitting_out, :boolean
  end
end
