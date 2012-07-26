ActiveSupport::Notifications.subscribe "deliver.action_mailer" do |name, start, finish, id, payload|
  attrs = payload.dup.stringify_keys
  %w(from to cc bcc).each do |key|
    attrs[key] = attrs[key].join(", ") if attrs.has_key?(key)
  end
  Notification.create(attrs.slice(*Notification.column_names))
end
