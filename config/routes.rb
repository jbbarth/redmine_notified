RedmineApp::Application.routes.draw do
  get 'notified/:id', :to => 'notified#show', :as => 'notified'
  post 'issues/:issue_id/resend_last_notification', to: 'issues#resend_last_notification' , as: :resend_last_notification
end
