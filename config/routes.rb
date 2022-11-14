RedmineApp::Application.routes.draw do
  get 'notified/:id', :to => 'notified#show', :as => 'notified'
end
