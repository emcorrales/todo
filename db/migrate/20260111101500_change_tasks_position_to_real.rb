class ChangeTasksPositionToReal < ActiveRecord::Migration[8.1]
  def up
    change_column :tasks, :position, :float, null: false, default: 0.0
  end

  def down
    change_column :tasks, :position, :integer, null: false, default: 0
  end
end
