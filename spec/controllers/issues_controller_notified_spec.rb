require File.dirname(__FILE__) + '/../spec_helper'

describe IssuesController, type: :controller do

  render_views

  fixtures :projects, :users, :roles, :members, :member_roles, :issues, :issue_statuses, :versions,
           :trackers, :projects_trackers, :issue_categories, :enabled_modules, :enumerations, :attachments,
           :workflows, :custom_fields, :custom_values, :custom_fields_projects, :custom_fields_trackers,
           :time_entries, :journals, :journal_details, :queries, :repositories, :changesets, :email_addresses

  include Redmine::I18n

  before do
    @request.session[:user_id] = 1 #permissions are hard
  end

  it "should new issue should display users that will be notified" do
    with_settings :default_language => "en", :plugin_redmine_notified => {'display_notified_users_in_forms' => '1'} do
      get :new, params: {:project_id => 1, :tracker_id => 1}
      expect(response).to be_successful
      assert_template 'new'
      assert_select '.notified' do
        assert_select 'a', '~3 users will be notified'
        assert_select '.notified_users' do
          assert_select '.person', :count => 3
        end
      end
    end
  end

  it "should edit issue should display users that will be notified" do
    with_settings :default_language => "en", :plugin_redmine_notified => {'display_notified_users_in_forms' => '1'} do
      get :show, params: {:id => 1}
      expect(response).to be_successful
      assert_template 'show'
      assert_select '.notified' do
        assert_select 'a', '~2 users will be notified'
        assert_select '.notified_users' do
          assert_select '.person', :count => 2
        end
      end
    end
  end

  it "should new issue should NOT display users that will be notified if setting says 'no'" do
    with_settings :default_language => "en", :plugin_redmine_notified => {'display_notified_users_in_forms' => '0'} do
      get :new, params: {:project_id => 1, :tracker_id => 1}
      expect(response).to be_successful
      assert_template 'new'
      assert_select '.notified', :count => 0
    end
  end

  it "does not show link (Resend last notification) without permission" do
    User.current = User.find(3)
    @request.session[:user_id] = 3
    get :show, params: { :id => 1 }

    expect(response.body).not_to have_content('Resend last notification')
  end

  it "shows link (Resend last notification) with permission" do
    User.current = User.find(3)
    @request.session[:user_id] = 3
    Role.find(2).add_permission!(:resend_last_notification)

    get :show, params: { :id => 1 }

    expect(response.body).to have_content('Resend last notification')
  end

  it "re-sends the last notifications for journal (new issue)" do
    post :create, params: {:project_id => 1, :issue => {:tracker_id => 3,
                                            :subject => 'This is the test_new issue',
                                            :description => 'This is the description',
                                            :priority_id => 5,
                                            :assigned_to => 2,
                                            :watcher_user_ids => [1,2]
                          }}

    issue_test = Issue.last

    expect(ActionMailer::Base.deliveries.size).to eq 3
    ActionMailer::Base.deliveries.clear

    expect do
      post :resend_last_notification, params: { :issue_id => issue_test.id }
    end.to change { Journal.count }.by(1)
    .and change { ActionMailer::Base.deliveries.size }.by(3)

    expect(response).to redirect_to("/issues/#{issue_test.id}")

    last_notif = Notification.last
    email = ActionMailer::Base.deliveries.last

    expect(Journal.last.journalized_type).to eq "Notification"
    expect(Journal.last.journalized_id).to eq last_notif.id
    expect(Journal.last.notes).to eq email.subject
    expect(Journal.last.notes).to eq last_notif.subject

  end

  it "re-sends the last notifications for journal (edit issue)" do
    put :update, params: {:id => 1, :issue => { :notes => 'note test'} }

    expect(ActionMailer::Base.deliveries.size).to eq 2
    ActionMailer::Base.deliveries.clear

    expect do
      post :resend_last_notification, params: { :issue_id => 1 }
    end.to change { Journal.count }.by(1)
    .and change { ActionMailer::Base.deliveries.size }.by(2)

    last_notif = Notification.last
    email = ActionMailer::Base.deliveries.last

    expect(response).to redirect_to("/issues/1")
    expect(Journal.last.journalized_type).to eq "Notification"
    expect(Journal.last.journalized_id).to eq last_notif.id
    expect(Journal.last.notes).to eq email.subject
    expect(Journal.last.notes).to eq last_notif.subject

    get :show, params: { :id => 1 }

    expect(response.body).to have_css("div[class='issue-mail-notification-container']")
    expect(response.body).to have_css("h4[class='note-header']", text: "Resend last notification to the addresses of people notified ago ")
  end

end
