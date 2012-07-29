Deface::Override.new :virtual_path  => 'issues/new.html',
                     :name          => 'add-notified-users-in-issues-new',
                     :insert_bottom => 'div.tabular',
                     :partial       => 'issues/notified_users_form'

Deface::Override.new :virtual_path  => 'issues/_edit.html',
                     :name          => 'add-notified-users-in-issues-edit',
                     :insert_bottom => 'fieldset:contains("label_change_properties")',
                     :partial       => 'issues/notified_users_form'
