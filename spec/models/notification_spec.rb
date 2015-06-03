require File.expand_path('../../spec_helper', __FILE__)

describe "Notification" do
  include Redmine::I18n
  include ActionDispatch::Assertions::SelectorAssertions
  fixtures :projects, :enabled_modules, :issues, :users, :members,
           :member_roles, :roles, :documents, :attachments, :news,
           :tokens, :journals, :journal_details, :changesets,
           :trackers, :projects_trackers, :versions, :comments,
           :issue_statuses, :enumerations, :messages, :boards, :repositories,
           :wikis, :wiki_pages, :wiki_contents, :wiki_content_versions

  before do
    ActionMailer::Base.deliveries.clear
    Setting.default_language = 'en'
    Setting.host_name = 'mydomain.foo'
    Setting.protocol = 'http'
    Setting.plain_text_mail = '0'
    Setting.bcc_recipients = '1'
  end

  it "should notification infers object from message_id before save" do
    issue = Issue.find(1)
    notif = Notification.create(:message_id => "redmine.issue-1.blah")
    notif.reload.notificable.should == issue
  end

  it "should notification resists even if it doesn't find a notificable from message_id" do
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

  it "should notification is created after mail is sent and auto-detects object" do
    issue = Issue.find(1)
    Mailer.deliver_issue_add(issue)
    mail = last_email
    notif = Notification.last
    notif.subject.should == mail.subject
    notif.message_id.should == mail.message_id
    notif.notificable.should == issue
    assert_nil notif.mail
  end

  it "should inverse associations are set correctly" do
    [Issue, Journal, News, Comment, Message, WikiContent].each do |klass|
      klass.reflect_on_all_associations.map(&:name).include?(:notifications).should == true
    end
  end

  #taken from test/unit/mailer_test.rb in core
  private
  def last_email
    mail = ActionMailer::Base.deliveries.last
    refute_nil mail
    mail
  end
end
