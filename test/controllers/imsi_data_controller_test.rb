require 'test_helper'

class ImsiDataControllerTest < ActionController::TestCase
  setup do
    @imsi_datum = imsi_data(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:imsi_data)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create imsi_datum" do
    assert_difference('ImsiDatum.count') do
      post :create, imsi_datum: { aimsicd_thread_level: @imsi_datum.aimsicd_thread_level }
    end

    assert_redirected_to imsi_datum_path(assigns(:imsi_datum))
  end

  test "should show imsi_datum" do
    get :show, id: @imsi_datum
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @imsi_datum
    assert_response :success
  end

  test "should update imsi_datum" do
    patch :update, id: @imsi_datum, imsi_datum: { aimsicd_thread_level: @imsi_datum.aimsicd_thread_level }
    assert_redirected_to imsi_datum_path(assigns(:imsi_datum))
  end

  test "should destroy imsi_datum" do
    assert_difference('ImsiDatum.count', -1) do
      delete :destroy, id: @imsi_datum
    end

    assert_redirected_to imsi_data_path
  end
end
