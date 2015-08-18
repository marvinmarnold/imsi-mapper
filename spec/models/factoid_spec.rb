require 'rails_helper'

RSpec.describe Factoid, type: :model do
 # pending "add some examples to (or delete) #{__FILE__}"
  
  
    it "has a valid factory" do
        expect(FactoryGirl.create(:factoid)).to be_valid
    end


end

