require "spec_helper"
require "active_support/testing/assertions"

def log_user(login, password)
  visit '/my/page'
  expect(current_path).to eq '/login'

  if Redmine::Plugin.installed?(:redmine_scn)
    click_on("ou s'authentifier par login / mot de passe")
  end

  within('#login-form form') do
    fill_in 'username', with: login
    fill_in 'password', with: password
    find('input[name=login]').click
  end
  expect(current_path).to eq '/my/page'
end

describe "issue/show", type: :system do
  include ActiveSupport::Testing::Assertions

  fixtures :projects, :users, :issues, :journals

  let!(:issue) { Issue.find(1) }
  let!(:journal) { issue.journals.first }
  let!(:user_jsmith) { User.find(2) }

  before do
    Journal.create(notes: "Private note test_1",
               journalized: issue,
               user_id: 1,
               private_notes: true,
               created_on: "2023-08-25 13:47:29") #1

    Journal.create(notes: "Note test_1",
               journalized: issue,
               user_id: 1,
               private_notes: false,
               created_on: "2023-08-26 13:48:29")  #2

    notification_1 = Notification.new(message_id: 1,
                                notificable_type: "journal",
                                notificable_id: journal.id,
                                created_at: "2023-08-27 13:49:29")
    notification_1.save

    Journal.skip_callback(:commit, :after, :send_notification)

    Journal.create(notes: "Note test_1",
               journalized: notification_1,
               user_id: 1,
               private_notes: false,
               created_on: "2023-08-26 13:48:29")

    Journal.set_callback(:commit, :after, :send_notification)

    Journal.create(notes: "Private note test_2",
               journalized: issue,
               user_id: 1,
               private_notes: true,
               created_on: "2023-08-28 13:50:29")  #4

    Journal.create(notes: "Note test_2",
               journalized: issue,
               user_id: 1,
               private_notes: false,
               created_on: "2023-08-29 13:51:29")  #5
  end

  it "Should show correct note number in case of non-admin user does not have the permission view_private_notes" do
    log_user('dlopper', 'foo')
    visit '/issues/1'
    expect(page).not_to have_selector(".journal-link", text: "#1")
    expect(page).to have_selector(".journal-link", text: "#2")
    expect(page).not_to have_selector(".journal-link", text: "#3")
    expect(page).to have_selector(".journal-link", text: "#4")
    expect(page).to have_selector(".journal-link", text: "#")
  end

  it "Should show correct note number in case of non-admin user has the permission view_private_notes" do
    log_user('jsmith', 'jsmith')
    visit '/issues/1'
    expect(page).to have_selector(".journal-link", text: "#1")
    expect(page).to have_selector(".journal-link", text: "#2")
    expect(page).to have_selector(".journal-link", text: "#3")
    expect(page).to have_selector(".journal-link", text: "#4")
    expect(page).to have_selector(".journal-link", text: "#")
  end
end