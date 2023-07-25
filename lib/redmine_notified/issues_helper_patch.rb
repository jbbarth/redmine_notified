require_dependency 'issues_helper'

module RedmineNotified
    module IssuesHelper

    def re_sent_notifications_journals
      notification_ids = Notification.re_sent_last_notifications_issue(@issue.id).map(&:id)
      Journal.where(journalized_type: "Notification",  journalized_id: notification_ids)
    end

  end
end

IssuesHelper.prepend RedmineNotified::IssuesHelper
ActionView::Base.prepend IssuesHelper
