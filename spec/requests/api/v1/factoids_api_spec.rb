require 'rails_helper'

describe "Factoids API" do
    it 'lets you read multiple factoids' do
        FactoryGirl.create_list(:factoid,10)

        get '/factoids'
        expect(response).to be_success            # test for the 200 status-code
        json = JSON.parse(response.body)
        expect(json.length).to eq(10)
        json.each do |factoid|
          expect(factoid).to include('fact')
          #STDERR.puts factoid
        end
    end
end
