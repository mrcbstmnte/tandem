class CreateCards < ActiveRecord::Migration[8.1]
  def change
    create_table :cards do |t|
      t.references :board, null: false, foreign_key: true
      t.string :title, null: false
      t.integer :status, null: false, default: 0
      t.integer :position, null: false, default: 0

      t.timestamps
    end
    add_index :cards, [ :board_id, :status, :position ]
  end
end
