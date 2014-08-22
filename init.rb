require 'redmine'
require 'redmine_notified/hooks'
require 'redmine_notified/mail_notifications_subscriber'

# Little hack for using the 'deface' gem in redmine:
# - redmine plugins are not railties nor engines, so deface overrides in app/overrides/ are not detected automatically
# - deface doesn't support direct loading anymore ; it unloads everything at boot so that reload in dev works
# - hack consists in adding "app/overrides" path of the plugin in Redmine's main #paths
# TODO: see if it's complicated to turn a plugin into a Railtie or find something a bit cleaner
Rails.application.paths["app/overrides"] ||= []
Rails.application.paths["app/overrides"] << File.expand_path("../app/overrides", __FILE__)

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
  requires_redmine_plugin :redmine_base_rspec, :version_or_higher => '0.0.3' if Rails.env.test?
  project_module :issue_tracking do
    permission :view_notified_users, { :notified => [:show] }
  end
  settings :partial => 'settings/notified_settings',
           :default => {
             'display_notified_users_in_forms' => '0'
           }
end
