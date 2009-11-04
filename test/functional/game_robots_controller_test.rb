require 'test_helper'

class GameRobotsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:game_robots)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create game_robot" do
    assert_difference('GameRobot.count') do
      post :create, :game_robot => { }
    end

    assert_redirected_to game_robot_path(assigns(:game_robot))
  end

  test "should show game_robot" do
    get :show, :id => game_robots(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => game_robots(:one).to_param
    assert_response :success
  end

  test "should update game_robot" do
    put :update, :id => game_robots(:one).to_param, :game_robot => { }
    assert_redirected_to game_robot_path(assigns(:game_robot))
  end

  test "should destroy game_robot" do
    assert_difference('GameRobot.count', -1) do
      delete :destroy, :id => game_robots(:one).to_param
    end

    assert_redirected_to game_robots_path
  end
end
