module NotificationsAssociationPatch
  def self.included(base)
    base.class_eval do
      has_many :notifications, :as => :notificable
    end
  end
end

%w(issue journal news comment message wiki_content).each do |klass|
  require_dependency klass
  klass.camelize.constantize.send(:include, NotificationsAssociationPatch)
end
