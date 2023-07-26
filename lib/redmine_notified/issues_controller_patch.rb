require_dependency 'issues_controller'

class IssuesController
  skip_before_action :authorize, :only => [:resend_last_notification]

  def resend_last_notification
    if params[:issue_id].present?

      issue = Issue.find(params[:issue_id])
      return render_403 unless User.current.allowed_to?(:resend_last_notification, issue.project)

      # find the last journal for this issue else it is a new issue
      journal = Journal.where(journalized: issue).last

      # if (ActiveJob::QueueAdapters::AsyncAdapter max_threads > 1) perhaps notifs.count > 1 else notifs.count = 1

      if journal.present?
        # Edition
        notifs = Notification.where(notificable: journal)
        notifs.each do |notif|
          Mailer.deliver_issue_edit(journal)
          create_journal_without_callbacks(notif)
        end
      else
        # Creation
        notifs = Notification.where(notificable: issue)
        notifs.each do |notif|
          Mailer.deliver_issue_add(issue)
          create_journal_without_callbacks(notif)
        end
      end
    end

    redirect_to issue
  end

  private

  def create_journal_without_callbacks(notif, user = User.current)
    # avoid to call  after_create_commit: send_notification
    Journal.skip_callback(:commit, :after, :send_notification)
    Journal.create(journalized: notif,
                   user: user,
                   notes: notif.subject)
    Journal.set_callback(:commit, :after, :send_notification)
  end
end
