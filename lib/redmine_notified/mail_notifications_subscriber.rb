ActiveSupport::Notifications.subscribe "deliver.action_mailer" do |name, start, finish, id, payload|
  attrs = payload.dup.stringify_keys
  %w(from to cc bcc).each do |key|
    attrs[key] = attrs[key].join(", ") if attrs.has_key?(key)
  end
  attrs['mail'] = nil
  begin
    new_notif = Notification.new(attrs.slice(*Notification.column_names))
    new_notif.infer_object_from_message_id
    old_notif = Notification.where(:notificable_type => new_notif.notificable_type, :notificable_id => new_notif.notificable_id).first
    if old_notif
      old_notif.bcc = (old_notif.bcc.split(', ') | new_notif.bcc.split(', ')).join(", ")
      old_notif.save
    else
      new_notif.save
    end
  rescue
    #this shouldn't happen, but hey, we don't want to prevent ticket creation if anything fails
    Rails.logger.error("ERROR: redmine_notified plugin, unable to add notification for #{attrs.inspect}")
  end
end
