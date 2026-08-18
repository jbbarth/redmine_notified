Deface::Override.new :virtual_path  => 'issues/new',
                     :name          => 'add-notified-users-in-issues-new',
                     :insert_after  => '#attachments_form',
                     :partial       => 'issues/notified_users_form'

Deface::Override.new :virtual_path  => 'issues/_edit',
                     :name          => 'add-notified-users-in-issues-edit',
                     :insert_bottom => 'fieldset:contains("field_notes")',
                     :partial       => 'issues/notified_users_form'
