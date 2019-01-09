class DeleteAllMailsInNotifications < ActiveRecord::Migration[4.2]
  def change
    Notification.update_all 'mail=NULL'
  end
end
