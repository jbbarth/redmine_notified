class AddMissingIndicesToNotifications < ActiveRecord::Migration
  def self.up
    add_index :notifications, :notificable_id
    add_index :notifications, :notificable_type
  end

  def self.down
    remove_index :notifications, :notificable_type
    remove_index :notifications, :notificable_id
  end
end
