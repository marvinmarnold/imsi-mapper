require 'test_helper'

class WifiDataControllerTest < ActionController::TestCase
  setup do
    @wifi_datum = wifi_data(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:wifi_data)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create wifi_datum" do
    assert_difference('WifiDatum.count') do
      post :create, wifi_datum: { latitude_degrees: @wifi_datum.latitude_degrees, longitude_degrees: @wifi_datum.longitude_degrees, num_wifi_hotspots: @wifi_datum.num_wifi_hotspots }
    end

    assert_redirected_to wifi_datum_path(assigns(:wifi_datum))
  end

  test "should show wifi_datum" do
    get :show, id: @wifi_datum
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @wifi_datum
    assert_response :success
  end

  test "should update wifi_datum" do
    patch :update, id: @wifi_datum, wifi_datum: { latitude_degrees: @wifi_datum.latitude_degrees, longitude_degrees: @wifi_datum.longitude_degrees, num_wifi_hotspots: @wifi_datum.num_wifi_hotspots }
    assert_redirected_to wifi_datum_path(assigns(:wifi_datum))
  end

  test "should destroy wifi_datum" do
    assert_difference('WifiDatum.count', -1) do
      delete :destroy, id: @wifi_datum
    end

    assert_redirected_to wifi_data_path
  end
end
