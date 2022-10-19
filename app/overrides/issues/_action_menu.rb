Deface::Override.new :virtual_path  => 'issues/_action_menu',
                     :name          => 'add-link-resend-button-to-issue-actions',
                     :insert_top    => '.contextual',
                     :text          => '<% if User.current.allowed_to?(:resend_last_notification, @project) %><%= link_to l(:permission_resend_last_notification), resend_last_notification_path(issue_id: @issue.id), :method => :post, :class => "icon icon-notified" %><% end %>'