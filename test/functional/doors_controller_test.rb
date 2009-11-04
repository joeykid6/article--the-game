require 'test_helper'

class DoorsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:doors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create door" do
    assert_difference('Door.count') do
      post :create, :door => { }
    end

    assert_redirected_to door_path(assigns(:door))
  end

  test "should show door" do
    get :show, :id => doors(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => doors(:one).to_param
    assert_response :success
  end

  test "should update door" do
    put :update, :id => doors(:one).to_param, :door => { }
    assert_redirected_to door_path(assigns(:door))
  end

  test "should destroy door" do
    assert_difference('Door.count', -1) do
      delete :destroy, :id => doors(:one).to_param
    end

    assert_redirected_to doors_path
  end
end
