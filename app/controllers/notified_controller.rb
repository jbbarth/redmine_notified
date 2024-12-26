class NotifiedController < ApplicationController

  before_action :find_issue
  before_action :authorize

  def show
    @issue_notifications = Notification.where("notificable_type = 'Issue' AND notificable_id = ?", @issue.id)
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
