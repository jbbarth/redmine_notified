class Notification < ActiveRecord::Base
  include Redmine::SafeAttributes

  belongs_to :notificable, :polymorphic => true

  before_save :infer_object_from_message_id

  safe_attributes :mailer, :message_id, :mail, :date, :subject, :to, :from, :bcc

  # Notification.infer_object_from_message_id(string)
  #   inverse of Mailer.message_id_for(object)
  #   deduces #notificable object, for which the #message_id has been issued
  def infer_object_from_message_id
    object_class_name, object_id = message_id.scan(/redmine\.([^-]+)-(\d+)/).first
    if object_class_name.present? && object_id.present?
      object_class = object_class_name.camelize.constantize
      self.notificable = object_class.find(object_id)
    end
    true
  rescue NameError, ActiveRecord::RecordNotFound
    Rails.logger.error "Plugin redmine_notified: unable to find an object for message_id=#{message_id}" unless Rails.env.test?
    self.notificable = nil
    true
  end

  scope :re_sent_last_notifications_issue, (lambda do |issue_id|
    ids = Issue.find(issue_id).journals.map(&:id)
    ids << issue_id
    ids.any? ? where(:notificable_id => ids) : none
  end)

end
