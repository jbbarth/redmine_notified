require File.dirname(__FILE__) + '/../test_helper'

class IssuesControllerNotifiedTest < ActionController::TestCase
  fixtures :projects, :users, :roles, :members, :member_roles, :issues, :issue_statuses, :versions,
           :trackers, :projects_trackers, :issue_categories, :enabled_modules, :enumerations, :attachments,
           :workflows, :custom_fields, :custom_values, :custom_fields_projects, :custom_fields_trackers,
           :time_entries, :journals, :journal_details, :queries, :repositories, :changesets

  include Redmine::I18n

  setup do
    @controller = IssuesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
    @request.session[:user_id] = 2
  end

  test "new issue should display users that will be notified" do
    with_settings :default_language => "en" do
      get :new, :project_id => 1, :tracker_id => 1
      assert_response :success
      assert_template 'new'
      assert_select '.notified' do
        assert_select 'a', '2 users will be notified'
        assert_select '.notified_users' do
          assert_select '.person', :count => 2
        end
      end
    end
  end
  
  test "edit issue should display users that will be notified" do
    with_settings :default_language => "en" do
      get :show, :id => 1
      assert_response :success
      assert_response :success
      assert_template 'show'
      assert_select '.notified' do
        assert_select 'a', '2 users will be notified'
        assert_select '.notified_users' do
          assert_select '.person', :count => 2
        end
      end
    end
  end
end
