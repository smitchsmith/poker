class CreateHands < ActiveRecord::Migration[6.0]
  def change
    create_table :hands do |t|
      t.integer :table_id
      t.integer :dealer_id
      t.string  :cards, array: true, default: []

      t.timestamps
    end
  end
end
