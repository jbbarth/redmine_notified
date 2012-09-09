Deface::Override.new :virtual_path  => 'issues/new',
                     :original      => '2f69a4138473a22e544a1fe043d9874aae820445',
                     :name          => 'add-notified-users-in-issues-new',
                     :insert_bottom => 'div.tabular',
                     :partial       => 'issues/notified_users_form'

Deface::Override.new :virtual_path  => 'issues/_edit',
                     :original      => '15c25198ca7b9049abbd5f1c32c2d4c6da4c285e',
                     :name          => 'add-notified-users-in-issues-edit',
                     :insert_bottom => 'fieldset:contains("label_change_properties")',
                     :partial       => 'issues/notified_users_form'
