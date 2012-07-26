require File.expand_path('../../test_helper', __FILE__)

class NotificationTest < ActiveSupport::TestCase
  include Redmine::I18n
  include ActionDispatch::Assertions::SelectorAssertions
  fixtures :projects, :enabled_modules, :issues, :users, :members,
           :member_roles, :roles, :documents, :attachments, :news,
           :tokens, :journals, :journal_details, :changesets,
           :trackers, :projects_trackers, :versions, :comments,
           :issue_statuses, :enumerations, :messages, :boards, :repositories,
           :wikis, :wiki_pages, :wiki_contents, :wiki_content_versions

  setup do
    ActionMailer::Base.deliveries.clear
    Setting.default_language = 'en'
    Setting.host_name = 'mydomain.foo'
    Setting.protocol = 'http'
    Setting.plain_text_mail = '0'
    Setting.bcc_recipients = '1'
  end

  test "notification infers object from message_id before save" do
    issue = Issue.find(1)
    notif = Notification.create(:message_id => "redmine.issue-1.blah")
    assert_equal issue, notif.reload.notificable
  end

  test "notification resists even if it doesn't find a notificable from message_id" do
    #no message_id
    notif = Notification.create
    assert_nil notif.reload.notificable
    #bad class name
    notif = Notification.create(:message_id => "redmine.issuez-1.blah")
    assert_nil notif.reload.notificable
    #bad id
    id = Issue.maximum(:id) || 0
    notif = Notification.create(:message_id => "redmine.issue-#{id + 1}.blah")
    assert_nil notif.reload.notificable
  end

  test "notification is created after mail is sent and auto-detects object" do
    issue = Issue.find(1)
    Mailer.issue_add(issue).deliver
    mail = last_email
    notif = Notification.last
    assert_equal mail.subject, notif.subject
    assert_equal mail.message_id, notif.message_id
    assert_equal issue, notif.notificable
  end

  #taken from test/unit/mailer_test.rb in core
  private
  def last_email
    mail = ActionMailer::Base.deliveries.last
    assert_not_nil mail
    mail
  end
end
