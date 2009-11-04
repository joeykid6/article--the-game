require 'test_helper'

class GameAvatarsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:game_avatars)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create game_avatar" do
    assert_difference('GameAvatar.count') do
      post :create, :game_avatar => { }
    end

    assert_redirected_to game_avatar_path(assigns(:game_avatar))
  end

  test "should show game_avatar" do
    get :show, :id => game_avatars(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => game_avatars(:one).to_param
    assert_response :success
  end

  test "should update game_avatar" do
    put :update, :id => game_avatars(:one).to_param, :game_avatar => { }
    assert_redirected_to game_avatar_path(assigns(:game_avatar))
  end

  test "should destroy game_avatar" do
    assert_difference('GameAvatar.count', -1) do
      delete :destroy, :id => game_avatars(:one).to_param
    end

    assert_redirected_to game_avatars_path
  end
end
