require File.expand_path('../../test_helper', __FILE__)

class NotifiedControllerTest < ActionController::TestCase
  tests IssuesController
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :issue_statuses,
           :trackers,
           :projects_trackers,
           :enabled_modules,
           :enumerations,
           :workflows

  # tests with custom field visibility by roles (added in Redmine 2.5)
  def setup
    CustomField.delete_all
    Issue.delete_all

    field_attributes = {:field_format => 'string', :is_for_all => true, :is_filter => true, :trackers => Tracker.all}
    @fields = []
    @fields << (@field1 = IssueCustomField.create!(field_attributes.merge(:name => 'Field 1', :visible => true)))
    @fields << (@field2 = IssueCustomField.create!(field_attributes.merge(:name => 'Field 2', :visible => false, :role_ids => [1, 2])))
    @fields << (@field3 = IssueCustomField.create!(field_attributes.merge(:name => 'Field 3', :visible => false, :role_ids => [1, 3])))
    @issue = Issue.generate!(
        :author_id => 1,
        :project_id => 1,
        :tracker_id => 1,
        :subject => "Generation",
        :custom_field_values => {@field1.id => 'Value0', @field2.id => 'Value1', @field3.id => 'Value2'}
    )

    @user_with_role_on_other_project = User.generate!
    User.add_to_project(@user_with_role_on_other_project, Project.find(2), Role.find(3))

    @users_to_test = {
        User.find(1) => [@field1, @field2, @field3],
        User.find(3) => [@field1, @field2],
        @user_with_role_on_other_project => [@field1], # should see field1 only on Project 1
        User.generate! => [@field1],
        User.anonymous => [@field1]
    }

    Member.where(:project_id => 1).each do |member|
      member.destroy unless @users_to_test.keys.include?(member.principal)
    end
  end

  def test_create_should_send_emails_according_custom_fields_visibility_and_create_only_one_notification
    # anonymous user is never notified
    users_to_test = @users_to_test.reject {|k,v| k.anonymous?}

    Notification.delete_all

    ActionMailer::Base.deliveries.clear
    @request.session[:user_id] = 1
    with_settings :bcc_recipients => '1' do
      assert_difference 'Issue.count' do
        post :create,
             :project_id => 1,
             :issue => {
                 :tracker_id => 1,
                 :status_id => 1,
                 :subject => 'New issue',
                 :priority_id => 5,
                 :custom_field_values => {@field1.id.to_s => 'Value0', @field2.id.to_s => 'Value1', @field3.id.to_s => 'Value2'},
                 :watcher_user_ids => users_to_test.keys.map(&:id)
             }
        assert_response 302
      end
    end

    notifs = Notification.all
    email = ActionMailer::Base.deliveries.first
    assert_equal email.subject, notifs.last.subject
    assert_equal email.message_id, notifs.last.message_id
    assert_equal Issue.last, notifs.last.notificable

    assert_equal 3, ActionMailer::Base.deliveries.size
    assert_equal 1, notifs.size

    assert_equal users_to_test.values.uniq.size, ActionMailer::Base.deliveries.size
    # tests that each user receives 1 email with the custom fields he is allowed to see only
    users_to_test.each do |user, fields|
      mails = ActionMailer::Base.deliveries.select {|m| m.bcc.include? user.mail}
      assert_equal 1, mails.size
      assert_include user.mail, notifs.first.bcc
    end
  end

  def test_update_should_send_emails_according_custom_fields_visibility_and_create_only_one_notification
    # anonymous user is never notified
    users_to_test = @users_to_test.reject {|k,v| k.anonymous?}

    Notification.delete_all

    users_to_test.keys.each do |user|
      Watcher.create!(:user => user, :watchable => @issue)
    end
    ActionMailer::Base.deliveries.clear
    @request.session[:user_id] = 1
    with_settings :bcc_recipients => '1' do
      put :update,
          :id => @issue.id,
          :issue => {
              :custom_field_values => {@field1.id.to_s => 'NewValue0', @field2.id.to_s => 'NewValue1', @field3.id.to_s => 'NewValue2'}
          }
      assert_response 302
    end

    notifs = Notification.all
    email = ActionMailer::Base.deliveries.first
    assert_equal email.subject, notifs.last.subject
    assert_equal email.message_id, notifs.last.message_id
    assert_equal Journal.last, notifs.last.notificable

    assert_equal 3, ActionMailer::Base.deliveries.size
    assert_equal 1, notifs.size

    assert_equal users_to_test.values.uniq.size, ActionMailer::Base.deliveries.size
    # tests that each user receives 1 email with the custom fields he is allowed to see only
    users_to_test.each do |user, fields|
      mails = ActionMailer::Base.deliveries.select {|m| m.bcc.include? user.mail}
      assert_equal 1, mails.size
      mail = mails.first
      @fields.each_with_index do |field, i|
        if fields.include?(field)
          assert_mail_body_match "Value#{i}", mail, "User #{user.id} was not able to view #{field.name} in notification"
        else
          assert_mail_body_no_match "Value#{i}", mail, "User #{user.id} was able to view #{field.name} in notification"
        end
      end
      assert_include user.mail, notifs.first.bcc
    end
  end
end
