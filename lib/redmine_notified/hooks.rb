module RedmineNotified

  class Hooks < Redmine::Hook::ViewListener
    #adds our css on each page
    def view_layouts_base_html_head(context)
      stylesheet_link_tag('plugin', :plugin => "redmine_notified")
    end
  end

  class ModelHook < Redmine::Hook::Listener
    def after_plugins_loaded(_context = {})
      require_relative 'mail_notifications_subscriber'
      require_relative 'notifications_association_patch'
    end
  end

end
