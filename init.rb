require 'redmine'
require 'redmine_notified/hooks'
require 'redmine_notified/mail_notifications_subscriber'

ActionDispatch::Callbacks.to_prepare do
  require_dependency 'redmine_notified/notifications_association_patch'
end

Redmine::Plugin.register :redmine_notified do
  name 'Redmine Notified plugin'
  description 'This plugin helps you see notified users for issues'
  author 'Jean-Baptiste BARTH'
  author_url 'mailto:jeanbaptiste.barth@gmail.com'
  requires_redmine :version_or_higher => '2.5.0'
  version '0.0.1'
  url 'https://github.com/jbbarth/redmine_notified'
  requires_redmine_plugin :redmine_base_rspec, :version_or_higher => '0.0.4' if Rails.env.test?
  requires_redmine_plugin :redmine_base_deface, :version_or_higher => '0.0.1'
  project_module :issue_tracking do
    permission :view_notified_users, { :notified => [:show] }
  end
  settings :partial => 'settings/notified_settings',
           :default => {
             'display_notified_users_in_forms' => '0'
           }
end
