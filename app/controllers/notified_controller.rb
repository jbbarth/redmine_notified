class NotifiedController < ApplicationController
  unloadable

  def show
    @issue = Issue.where(:id => params[:id].to_i)
                  .first
    if @issue.present?
      @issue_notification = Notification.where("notificable_type = 'Issue' AND notificable_id = ?", @issue.id).first
      @journal_notifications = Notification.where("notificable_type = 'Journal' AND notificable_id IN (?)", @issue.journal_ids)
                                           .order("created_at asc")
      @journal_ids = @issue.journals.order("created_on asc").pluck(:id)
    end
  end
end
