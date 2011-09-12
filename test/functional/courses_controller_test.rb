require 'test_helper'

class CoursesControllerTest < ActionController::TestCase
  test "should get subject" do
    get :subject
    assert_response :success
  end

  test "should get course" do
    get :course
    assert_response :success
  end

  test "should get section" do
    get :section
    assert_response :success
  end

end
