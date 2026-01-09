class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :position, null: false, default: 0
      t.boolean :completed, null: false, default: false

      t.timestamps
    end

    add_index :tasks, [:user_id, :position]
  end
end
