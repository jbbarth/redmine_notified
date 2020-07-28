require File.expand_path('../../spec_helper', __FILE__)
require "active_support/testing/assertions"
require File.expand_path("../../../../../test/object_helpers", __FILE__)

describe IssuesController do
  include ActiveSupport::Testing::Assertions
  include ObjectHelpers

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
           :workflows,
           :email_addresses

  # tests with custom field visibility by roles (added in Redmine 2.5)
  before do
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
        User.find(2) => [@field1, @field2, @field3],
        User.find(3) => [@field1, @field2],
        @user_with_role_on_other_project => [@field1], # should see field1 only on Project 1
        User.generate! => [@field1],
        User.anonymous => [@field1]
    }

    Member.where(:project_id => 1).each do |member|
      member.destroy unless @users_to_test.keys.include?(member.principal)
    end
  end

  it "creates a new issue and sends emails according to custom fields visibility and create only one notification" do
    # anonymous user is never notified
    users_to_test = @users_to_test.reject { |k, v| k.anonymous? }

    Notification.delete_all

    ActionMailer::Base.deliveries.clear
    @request.session[:user_id] = 1
    with_settings :bcc_recipients => '1' do
      assert_difference 'Issue.count' do
        post :create, params: {
            :project_id => 1,
            :issue => {
                :tracker_id => 1,
                :status_id => 1,
                :subject => 'New issue',
                :priority_id => 5,
                :custom_field_values => {@field1.id.to_s => 'Value0', @field2.id.to_s => 'Value1', @field3.id.to_s => 'Value2'},
                :watcher_user_ids => users_to_test.keys.map(&:id)
            }}
        assert_response 302
      end
    end

    notifs = Notification.all
    email = ActionMailer::Base.deliveries.first
    expect(notifs.last.subject).to eq email.subject
    expect(notifs.last.message_id).to eq email.message_id
    expect(notifs.last.notificable).to eq Issue.last

    expect(ActionMailer::Base.deliveries.size).to eq 4
    expect(notifs.size).to eq 1

    expect(ActionMailer::Base.deliveries.size).to eq users_to_test.values.size
    # tests that each user receives 1 email with the custom fields he is allowed to see only
    users_to_test.each do |user, fields|
      mails = ActionMailer::Base.deliveries.select { |m| m.bcc.include? user.mail }
      expect(mails.size).to eq 1
      expect(notifs.first.bcc).to include(user.mail)
    end
  end

  it "updates an issue and sends emails according to custom fields visibility and create only one notification" do
    # anonymous user is never notified
    users_to_test = @users_to_test.reject { |k, v| k.anonymous? }

    Notification.delete_all

    users_to_test.keys.each do |user|
      Watcher.create!(:user => user, :watchable => @issue)
    end
    ActionMailer::Base.deliveries.clear
    @request.session[:user_id] = 1
    with_settings :bcc_recipients => '1' do
      put :update, params: {
          :id => @issue.id,
          :issue => {
              :custom_field_values => {@field1.id.to_s => 'NewValue0', @field2.id.to_s => 'NewValue1', @field3.id.to_s => 'NewValue2'}
          }}
      assert_response 302
    end

    notifs = Notification.all
    email = ActionMailer::Base.deliveries.first
    expect(notifs.last.subject).to eq email.subject
    expect(notifs.last.message_id).to eq email.message_id
    expect(notifs.last.notificable).to eq Journal.last

    expect(ActionMailer::Base.deliveries.size).to eq 4
    expect(notifs.size).to eq 1

    expect(ActionMailer::Base.deliveries.size).to eq users_to_test.values.size
    # tests that each user receives 1 email with the custom fields he is allowed to see only
    users_to_test.each do |user, fields|
      mails = ActionMailer::Base.deliveries.select { |m| m.bcc.include? user.mail }
      expect(mails.size).to eq 1
      mail = mails.first
      @fields.each_with_index do |field, i|
        if fields.include?(field)
          assert_mail_body_match "Value#{i}", mail, "User #{user.id} was not able to view #{field.name} in notification"
        else
          assert_mail_body_no_match "Value#{i}", mail, "User #{user.id} was able to view #{field.name} in notification"
        end
      end
      expect(notifs.first.bcc).to include(user.mail)
    end
  end
end
