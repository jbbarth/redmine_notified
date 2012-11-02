class NotifiedController < ApplicationController
  unloadable
  before_filter :find_issue
  before_filter :authorize

  def show
    @issue_notification = Notification.where("notificable_type = 'Issue' AND notificable_id = ?", @issue.id).first
    @journal_notifications = Notification.where("notificable_type = 'Journal' AND notificable_id IN (?)", @issue.journal_ids)
                                          .order("created_at asc")
    @journal_ids = @issue.journals.order("created_on asc").pluck(:id)
  end

  def find_issue
    @issue = Issue.find(params[:id].to_i)
    @project = @issue.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
