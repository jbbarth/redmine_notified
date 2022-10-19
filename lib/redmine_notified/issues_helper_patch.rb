require_dependency 'issues_helper'

module RedmineNotified
    module IssuesHelper

    def re_sent_notifications_journals
      result = []

      ids = Notification.re_sent_last_notifications_issue(@issue.id).map(&:id)
      @journaled_notifications = Journal.where(journalized_type: "Notification",  journalized_id: ids)
      @journaled_notifications.each do |journal|
        result  << journal
      end
      result
    end
  end
end

IssuesHelper.prepend RedmineNotified::IssuesHelper
ActionView::Base.prepend IssuesHelper