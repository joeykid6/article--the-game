require 'test_helper'

class MediaObjectsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:media_objects)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create media_object" do
    assert_difference('MediaObject.count') do
      post :create, :media_object => { }
    end

    assert_redirected_to media_object_path(assigns(:media_object))
  end

  test "should show media_object" do
    get :show, :id => media_objects(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => media_objects(:one).to_param
    assert_response :success
  end

  test "should update media_object" do
    put :update, :id => media_objects(:one).to_param, :media_object => { }
    assert_redirected_to media_object_path(assigns(:media_object))
  end

  test "should destroy media_object" do
    assert_difference('MediaObject.count', -1) do
      delete :destroy, :id => media_objects(:one).to_param
    end

    assert_redirected_to media_objects_path
  end
end
