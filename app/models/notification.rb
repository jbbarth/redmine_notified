class Notification < ActiveRecord::Base
  belongs_to :notificable, :polymorphic => true

  before_save :infer_object_from_message_id

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
    Rails.logger.error "Plugin redmine_notified: unable to find an object for message_id=#{message_id}"
    self.notificable = nil
    true
  end
end
