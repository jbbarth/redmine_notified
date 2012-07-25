require File.dirname(__FILE__) + '/../test_helper'

class IssuesControllerNotifiedTest < ActionController::TestCase
  def setup
    @controller = IssuesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
    @request.session[:user_id] = 2
  end
  
  test "new issue should display users that will be notified" do
    raise "reminder that I should write some tests when I'm back on a decent computer"
  end
  
  test "edit issue should display users that will be notified" do
    raise "reminder that I should write some tests when I'm back on a decent computer"
  end
end
