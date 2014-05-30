class DeleteAllMailsInNotifications < ActiveRecord::Migration
  def change
    Notification.update_all 'mail=NULL'
  end
end
