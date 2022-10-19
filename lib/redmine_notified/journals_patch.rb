require_dependency 'journal'

module RedmineNotified
  module JournalPatch
    # Stores the values of the attributes and custom fields of the journalized object
    # Patch to avoid overriding journalized_attribute_names and to avoid using acts_as_customizable
    def start
      ## start patch to avoid overrideing journalized_attribute_names and to avoid using acts_as_customizable
      if journalized_type == "Notification"
        self
      else
        # end patch
        super
      end

    end
  end
end

Journal.prepend RedmineNotified::JournalPatch