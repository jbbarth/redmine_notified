module RedmineNotified
  class Hooks < Redmine::Hook::ViewListener
    #adds our css on each page
    def view_layouts_base_html_head(context)
      stylesheet_link_tag('plugin', :plugin => "redmine_notified")
    end
  end
end
