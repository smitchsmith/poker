class AddActiveAndBlindsToTables < ActiveRecord::Migration[6.0]
  def change
    add_column :tables, :active, :boolean, default: true
    add_column :tables, :big_blind_amount, :integer
    add_column :tables, :small_blind_amount, :integer
    add_column :tables, :created_by_id, :integer
  end
end
