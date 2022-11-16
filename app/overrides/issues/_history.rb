Deface::Override.new :virtual_path  => 'issues/tabs/_history',
                     :name          => 'resend_notifs_are_not_editable',
                     :replace       => 'erb[loud]:contains("render_notes")',
                     :text          => <<EOS
<% if journal.persisted? && journal.journalized_type != "Notification" %>
  <%= render_notes(issue, journal, :reply_links => reply_links) unless journal.notes.blank? %>
<% elsif journal.journalized_type == "Notification" %>
  <%= render_notifications_history(issue, journal, :reply_links => reply_links)  %>
<% end %>
EOS

Deface::Override.new :virtual_path  => 'issues/tabs/_history',
                     :name          => 'resend_notifs_has_no_actions',
                     :replace       => 'erb[loud]:contains("render_journal_actions")',
                     :text          => <<EOS
<% if journal.persisted? && journal.journalized_type != "Notification" %>
  <%= render_journal_actions(issue, journal, :reply_links => reply_links) %>
<% end %>
EOS

Deface::Override.new :virtual_path  => 'issues/tabs/_history',
                     :name          => 'resend_notifs_have_no_author',
                     :replace       => 'erb[loud]:contains("authoring journal.created_on")',
                     :text          => <<EOS
<% if journal.persisted? && journal.journalized_type != "Notification" %>
  <%= authoring journal.created_on, journal.user, :label => :label_updated_time_by %>
<% else %>
    <%= l(:label_last_notifications_resent) %>
    <%= time_tag(journal.created_on).html_safe %>
    <% mail_id = "journal-"+journal.object_id.to_s+"-notes" %>
    <% link_id = "link-to-mail-notification-"+journal.object_id.to_s %>
    <%= content_tag(:span) { ('(' + content_tag(:a, l(:label_see_the_content_of_the_email), :href => "#", id: link_id, :onclick => "toggle_mail_details(event, '"+mail_id+"','"+link_id+"')" ) + ')').html_safe } %>
<% end %>
<script type="text/javascript">
  var toggle_mail_details = function(event, mail_id, link_id) {
    blockEventPropagation(event);
    $('#'+mail_id).toggleClass('hidden');
    if($('#'+mail_id).is(':visible')) {
      $('#'+link_id).text('<%= l(:label_hide_the_content_of_the_email) %>')
    }else{
      $('#'+link_id).text('<%= l(:label_see_the_content_of_the_email) %>')
    };
    return false;
  }
</script>
EOS

Deface::Override.new :virtual_path  => 'issues/tabs/_history',
                     :name          => 'add-container-to-mail-notifications',
                     :original      => '68e145deae6a29591c73e2ca568cbac07e2fdbd0',
                     :surround      => "div:contains(id, 'change-')",
                     :text          => <<-EOS
<% if journal.persisted? && journal.journalized_type != "Notification" %>
  <%= render_original %>
<% else %>
  <div class='issue-mail-notification-container' id='mail-notification-<%= journal.object_id %>'>
    <%= render_original %>
  </div>
<% end %>
EOS
