Deface::Override.new :virtual_path => 'issues/show',
                     :name         => 'add-notified-emails-for-issue-creation',
                     :insert_top   => 'div.subject',
                     :text         => '<% if User.current.allowed_to?(:view_notified_users, @project) %><div class="contextual is-notified"><%= link_to sprite_icon("email", l(:notified)), notified_path(@issue), :remote => true, :method => :get %></div><% end %>'
