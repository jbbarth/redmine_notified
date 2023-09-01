Deface::Override.new :virtual_path => 'issues/show',
                     :name         => 'add-notified-emails-for-issue-creation',
                     :insert_top   => 'div.subject',
                     :text         => '<% if User.current.allowed_to?(:view_notified_users, @project) %><div class="contextual is-notified"><%= link_to l(:notified), notified_path(@issue), :remote => true, :method => :get, :class => "icon icon-notified" %></div><% end %>'

Deface::Override.new :virtual_path  => 'issues/show',
                     :name          => 'add-issue-notifications-to-journals',
                     :insert_before  => 'h2',
                     :text          => <<EOS
<%
  @journals = @journals + re_sent_notifications_journals

  @journals.sort_by!(&:created_on)
  @journals.reverse! if User.current.wants_comments_in_reverse_order?
%>
EOS

