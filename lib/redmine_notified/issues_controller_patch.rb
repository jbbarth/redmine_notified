require_dependency 'issues_controller'

class IssuesController
  skip_before_action :authorize, :only => [:resend_last_notification]

  def resend_last_notification
    if params[:issue_id].present?
      # find the last journal for this issue else it is a new issue
      journal = Journal.where(journalized_type: "Issue",  journalized_id: params[:issue_id]).last

      if journal.present?
        notifs = Notification.where(notificable_type: "Journal",  notificable_id: journal.id)
        # if (ActiveJob::QueueAdapters::AsyncAdapter max_threads > 1) perhaps notifs.count > 1 else notifs.count = 1
        notifs.each do |notif|

          Mailer.deliver_issue_edit(journal)

          new_journal = Journal.new(journalized_id: notif.id, journalized_type: 'Notification',
            user: User.current, :notes => notif.subject)

          # avoid to call  after_create_commit: send_notification
          Journal.skip_callback(:commit, :after, :send_notification)
          new_journal.save!
          Journal.set_callback(:commit, :after, :send_notification)
        end
      else
        notifs = Notification.where(notificable_type: "Issue",  notificable_id: params[:issue_id])
        notifs.each do |notif|

          Mailer.deliver_issue_add(Issue.find(params[:issue_id]))
          new_journal = Journal.new(journalized_id: notif.id, journalized_type: 'Notification',
            user: User.current, :notes => notif.subject)

          # avoid to call  after_create_commit: send_notification
          Journal.skip_callback(:commit, :after, :send_notification)
          new_journal.save!
          Journal.set_callback(:commit, :after, :send_notification)
        end
      end

    end
  end
end