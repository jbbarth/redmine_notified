require_dependency 'issue'

class Issue
  # Returns the users that should be notified
  # NB: same as Issue#recipients, without the map(&:mail) at the end
  def notified_users
    notified = []
    # Author and assignee are always notified unless they have been
    # locked or don't want to be notified
    notified << author if author
    if assigned_to
      notified += (assigned_to.is_a?(Group) ? assigned_to.users : [assigned_to])
    end
    if assigned_to_was
      notified += (assigned_to_was.is_a?(Group) ? assigned_to_was.users : [assigned_to_was])
    end
    notified = notified.select {|u| u.active? && u.notify_about?(self)}

    notified += project.notified_users
    notified.uniq!
    # Remove users that can not view the issue
    notified.reject! {|user| !visible?(user)}
    # Return
    notified
  end
end
