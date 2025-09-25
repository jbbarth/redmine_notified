class AddMissingIndexes < ActiveRecord::Migration[6.1]
  def change
    add_index :notifications, [:notificable_id, :notificable_type], if_not_exists: true
  end
end
