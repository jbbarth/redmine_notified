ActiveSupport::Notifications.subscribe "deliver.action_mailer" do |name, start, finish, id, payload|
  attrs = payload.dup.stringify_keys
  %w(from to cc bcc).each do |key|
    attrs[key] = attrs[key].join(", ") if attrs.has_key?(key)
  end
  begin
    Notification.create(attrs.slice(*Notification.column_names))
  rescue
    #this shouldn't happen, but hey, we don't want to prevent ticket creation if anything fails
    Rails.logger.error("ERROR: redmine_notified plugin, unable to add notification for #{attrs.inspect}")
  end
end
