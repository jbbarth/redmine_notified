require File.expand_path('../../spec_helper', __FILE__)

describe "Notification" do
  include Redmine::I18n

  fixtures :projects, :enabled_modules, :issues, :users, :members,
           :member_roles, :roles, :documents, :attachments, :news,
           :tokens, :journals, :journal_details, :changesets,
           :trackers, :projects_trackers, :versions, :comments,
           :issue_statuses, :enumerations, :messages, :boards, :repositories,
           :wikis, :wiki_pages, :wiki_contents, :wiki_content_versions, :email_addresses

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
    expect(notif.reload.notificable).to eq issue
  end

  it "should notification resists even if it doesn't find a notificable from message_id" do
    #no message_id
    notif = Notification.create
    expect(notif.reload.notificable).to be_nil
    #bad class name
    notif = Notification.create(:message_id => "redmine.issuez-1.blah")
    expect(notif.reload.notificable).to be_nil
    #bad id
    id = Issue.maximum(:id) || 0
    notif = Notification.create(:message_id => "redmine.issue-#{id + 1}.blah")
    expect(notif.reload.notificable).to be_nil
  end

  it "should notification is created after mail is sent and auto-detects object" do
    issue = Issue.find(1)
    Mailer.deliver_issue_add(issue)
    mails = ActionMailer::Base.deliveries
    last_mail = mails.last
    expect(ActionMailer::Base.deliveries.size).to eq 2
    notif = Notification.last
    expect(notif.subject).to eq last_mail.subject
    expect(mails.map(&:message_id)).to include notif.message_id
    expect(notif.notificable).to eq issue

    expect(notif.mail).to be_nil
  end

  it "should inverse associations are set correctly" do
    [Issue, Journal, News, Comment, Message, WikiContent].each do |klass|
      expect(klass.reflect_on_all_associations.map(&:name).include?(:notifications)).to be true
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
