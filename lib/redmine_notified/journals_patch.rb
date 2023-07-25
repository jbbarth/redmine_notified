require_dependency 'journal'

module RedmineNotified
  module JournalPatch
    # Patch to avoid overriding journalized_attribute_names and to avoid using acts_as_customizable
    def start
      if journalized_type == "Notification"
        self
      else
        super
      end
    end
  end
end
Journal.prepend RedmineNotified::JournalPatch
