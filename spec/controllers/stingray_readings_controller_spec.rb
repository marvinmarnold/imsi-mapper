require 'rails_helper'

RSpec.describe StingrayReadingsController, type: :controller do
    context "with 0 readings" do
        describe "GET index" do
            it "has a 200 status code" do
              get :index
              expect(response.status).to eq(200)
            end
        end
    
        describe "index" do
            it "renders an empty json response" do
              get :index
              expect(response.body).to eq "[]"
            end
        end
    end 

end
