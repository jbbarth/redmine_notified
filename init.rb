#require 'redmine'

#ActionDispatch::Callbacks.to_prepare do
#end

Redmine::Plugin.register :redmine_notified do
  name 'Redmine Notified plugin'
  description 'This plugin helps you see notified users for issues'
  author 'Jean-Baptiste BARTH'
  author_url 'mailto:jeanbaptiste.barth@gmail.com'
  requires_redmine :version_or_higher => '2.0.3'
  version '0.0.1'
  url 'https://github.com/jbbarth/redmine_notified'
end