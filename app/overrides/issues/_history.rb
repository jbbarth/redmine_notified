Deface::Override.new :virtual_path  => 'issues/tabs/_history',
                     :name          => 'resend_notifs_are_not_editable',
                     :replace       => 'erb[loud]:contains("render_notes")',
                     :text          => <<'EOS'
<% if journal.journalized_type == "Issue" %>
  <%= render_notes(issue, journal, :reply_links => reply_links) unless journal.notes.blank? %>
<% else %>
  <% options = [:reply_links => reply_links] %>
  <%= send "render_notification_in_issue_history" , issue, journal, *options %>
<% end %>
EOS

Deface::Override.new :virtual_path  => 'issues/tabs/_history',
                     :name          => 'resend_notifs_has_no_actions',
                     :replace       => 'erb[loud]:contains("render_journal_actions")',
                     :text          => <<EOS
<% if journal.journalized_type == "Issue" %>
  <%= render_journal_actions(issue, journal, :reply_links => reply_links) %>
<% end %>
EOS

Deface::Override.new :virtual_path  => 'issues/tabs/_history',
                     :name          => 'resend_notifs_have_no_author',
                     :replace       => 'erb[loud]:contains("authoring journal.created_on")',
                     :partial       => 'issues/journal_authoring'
