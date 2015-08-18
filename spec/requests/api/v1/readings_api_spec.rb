
require 'spec_helper'

describe "StingrayReadings API" do
  it 'create a reading' do
    
    
    #FactoryGirl.create_list(:stingray_reading, 10)
  
    FactoryGirl.create(:stingray_reading)

    
    get '/stingray_readings/' # '/api/v1/messages'

    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    expect(json.length).to eq(1) # check to make sure the right amount of messages are returned
  end
  
end