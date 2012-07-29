Deface::Override.new :virtual_path  => 'issues/new',
                     :name          => 'add-notified-users-in-issues-new',
                     :insert_bottom => 'div.tabular',
                     :partial       => 'issues/notified_users_form'

Deface::Override.new :virtual_path  => 'issues/_edit',
                     :name          => 'add-notified-users-in-issues-edit',
                     :insert_bottom => 'fieldset:contains("label_change_properties")',
                     :partial       => 'issues/notified_users_form'
