require File.dirname(__FILE__) + '/../spec_helper'

describe IssuesController do
  render_views
  fixtures :projects, :users, :roles, :members, :member_roles, :issues, :issue_statuses, :versions,
           :trackers, :projects_trackers, :issue_categories, :enabled_modules, :enumerations, :attachments,
           :workflows, :custom_fields, :custom_values, :custom_fields_projects, :custom_fields_trackers,
           :time_entries, :journals, :journal_details, :queries, :repositories, :changesets

  include Redmine::I18n

  before do
    @controller = IssuesController.new
    @request = ActionDispatch::TestRequest.create
    @response = ActionDispatch::TestResponse.new
    User.current = nil
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
end
