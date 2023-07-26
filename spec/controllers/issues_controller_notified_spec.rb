require File.dirname(__FILE__) + '/../spec_helper'

describe IssuesController, type: :controller do

  render_views

  fixtures :projects, :users, :roles, :members, :member_roles, :issues, :issue_statuses, :versions,
           :trackers, :projects_trackers, :issue_categories, :enabled_modules, :enumerations, :attachments,
           :workflows, :custom_fields, :custom_values, :custom_fields_projects, :custom_fields_trackers,
           :time_entries, :journals, :journal_details, :queries, :repositories, :changesets, :email_addresses

  include Redmine::I18n

  before do
    @request.session[:user_id] = 1 # permissions are hard
  end

  it "displays users that will be notified when creating the issue" do
    with_settings :default_language => "en", :plugin_redmine_notified => { 'display_notified_users_in_forms' => '1' } do
      get :new, params: { :project_id => 1, :tracker_id => 1 }
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

  it "displays users that will be notified when editing the issue" do
    with_settings :default_language => "en", :plugin_redmine_notified => { 'display_notified_users_in_forms' => '1' } do
      get :show, params: { :id => 1 }
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

  it "does NOT display users that will be notified if setting says 'no'" do
    with_settings :default_language => "en", :plugin_redmine_notified => { 'display_notified_users_in_forms' => '0' } do
      get :new, params: { :project_id => 1, :tracker_id => 1 }
      expect(response).to be_successful
      assert_template 'new'
      assert_select '.notified', :count => 0
    end
  end

  describe "Resend last notification" do

    before do
      User.current = User.find(3)
      @request.session[:user_id] = 3
      Role.find(2).add_permission!(:resend_last_notification)

      # Ensure user_3 is notified of changes
      user_3 = User.find(3)
      user_3.pref.no_self_notified = false
      user_3.pref.save!
    end

    it "does not show link (Resend last notification) without permission" do
      Role.find(2).remove_permission!(:resend_last_notification)
      get :show, params: { :id => 1 }
      expect(response.body).not_to have_content('Resend last notification')
    end

    it "shows link (Resend last notification) with permission" do
      get :show, params: { :id => 1 }
      expect(response.body).to have_content('Resend last notification')
    end

    it "re-sends the last notification when issue is a new one" do
      ActionMailer::Base.deliveries.clear

      post :create, params: { :project_id => 1, :issue => { :tracker_id => 3,
                                                            :subject => 'This is the test_new issue',
                                                            :description => 'This is the description',
                                                            :priority_id => 5,
                                                            :assigned_to => 2 } }

      expect(ActionMailer::Base.deliveries.size).to eq 2
      ActionMailer::Base.deliveries.clear

      issue_test = Issue.last
      expect do
        post :resend_last_notification, params: { :issue_id => issue_test.id }
      end.to change { Journal.count }.by(1)
                                     .and change { ActionMailer::Base.deliveries.size }.by(2)

      expect(response).to redirect_to("/issues/#{issue_test.id}")

      last_notif = Notification.last
      email = ActionMailer::Base.deliveries.last
      last_journal = Journal.last
      expect(last_journal.journalized_type).to eq "Notification"
      expect(last_journal.journalized_id).to eq last_notif.id
      expect(last_journal.notes).to eq email.subject
      expect(last_journal.notes).to eq last_notif.subject
    end

    it "re-sends the last notification when the issue already have edits)" do
      ActionMailer::Base.deliveries.clear
      put :update, params: { :id => 1, :issue => { :notes => 'note test' } }
      expect(ActionMailer::Base.deliveries.size).to eq 2

      ActionMailer::Base.deliveries.clear
      expect do
        post :resend_last_notification, params: { :issue_id => 1 }
      end.to change { Journal.count }.by(1)
                                     .and change { ActionMailer::Base.deliveries.size }.by(2)

      expect(response).to redirect_to("/issues/1")

      last_notif = Notification.last
      email = ActionMailer::Base.deliveries.last
      last_journal = Journal.last
      expect(last_journal.journalized_type).to eq "Notification"
      expect(last_journal.journalized_id).to eq last_notif.id
      expect(last_journal.notes).to eq email.subject
      expect(last_journal.notes).to eq last_notif.subject

      get :show, params: { :id => 1 }
      expect(response.body).to have_css("h4[class='note-header']", text: "Notification manually re-sent by")
    end

    it "forbid an unauthorized user to resend last notification" do
      Role.find(2).remove_permission!(:resend_last_notification)

      ActionMailer::Base.deliveries.clear
      put :update, params: { :id => 1, :issue => { :notes => 'note test' } }
      expect(ActionMailer::Base.deliveries.size).to eq 2

      ActionMailer::Base.deliveries.clear
      expect do
        post :resend_last_notification, params: { :issue_id => 1 }
      end.to_not change { Journal.count }
      expect(ActionMailer::Base.deliveries).to be_empty

      expect(response).to have_http_status(:forbidden) # 403
    end

    it "resends the last public notes, not the privates ones" do
      Journal.create!(:journalized => Issue.find(1), :notes => 'note test visible by everyone', :private_notes => false)
      Journal.create!(:journalized => Issue.find(1), :notes => 'this is a private note', :private_notes => true)

      ActionMailer::Base.deliveries.clear
      expect do
        post :resend_last_notification, params: { :issue_id => 1 }
      end.to change { Journal.count }.by(1)
                                     .and change { ActionMailer::Base.deliveries.size }.by(2)

      expect(response).to redirect_to("/issues/1")

      resent_email = ActionMailer::Base.deliveries.last.body.parts.first.body.raw_source
      expect(resent_email).to_not include('this is a private note')
      expect(resent_email).to include('note test visible by everyone')
    end
  end

end
