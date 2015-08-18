require 'rails_helper'


#RSpec.describe FactoidsController, type: :controller do

describe "Factoids API" do

    it 'lets you create a factoid ' do
        
        f  = FactoryGirl.build(:factoid) 
        
        post "/factoids", :factoid => { 'fact' => f.fact }
        expect(response).to be_success            # test for the 200 status-code
        json = JSON.parse(response.body)
        #STDERR.puts json.inspect  
        
        expect(json['fact']).to eq(f.fact)
    end 
    
    it 'lets you read multiple factoids' do
    
        FactoryGirl.create_list(:factoid,10)
        # without token, expect only 3 decimal places
        get '/factoids'
        expect(response).to be_success            # test for the 200 status-code
        json = JSON.parse(response.body)
        expect(json.length).to eq(10)
        json.each do |factoid|
          expect(factoid).to include('fact')
          STDERR.puts factoid
        end
      
    end
    
    


end
