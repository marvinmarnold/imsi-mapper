require 'test_helper'

class StingrayReadingsControllerTest < ActionController::TestCase
  setup do
    @stingray_reading = stingray_readings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:stingray_readings)
  end

  test "should create stingray_reading" do
    assert_difference('StingrayReading.count') do
      post :create, stingray_reading: { lat: @stingray_reading.lat, long: @stingray_reading.long, observed_at: @stingray_reading.observed_at, threat_level: @stingray_reading.threat_level, version: @stingray_reading.version }
    end

    assert_response 201
  end

  test "should show stingray_reading" do
    get :show, id: @stingray_reading
    assert_response :success
  end

  test "should update stingray_reading" do
    put :update, id: @stingray_reading, stingray_reading: { lat: @stingray_reading.lat, long: @stingray_reading.long, observed_at: @stingray_reading.observed_at, threat_level: @stingray_reading.threat_level, version: @stingray_reading.version }
    assert_response 204
  end

  test "should destroy stingray_reading" do
    assert_difference('StingrayReading.count', -1) do
      delete :destroy, id: @stingray_reading
    end

    assert_response 204
  end
end
