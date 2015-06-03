class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
      t.column :notificable_type, :string
      t.column :notificable_id, :integer
      t.timestamps null: false
      #common ActionMailer fields included in the instrumentation
      t.column :mailer, :string
      t.column :message_id, :string
      t.column :mail, :text
      t.column :date, :date
      %w(subject to from cc bcc).each do |field|
        t.column field, :text #we cannot ensure length is < 255 so :text type is better
      end
    end
  end

  def self.down
    drop_table :notifications
  end
end
