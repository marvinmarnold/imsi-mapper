FactoryGirl.define do
  
  #factory :factoid do
  #  fact "MyString"
  #  created_at "2015-08-18 21:31:06"
  #end

    factory :factoid do
       
       fact { "You've got " + rand(2..99).to_s + " problems and this silly remark likely isn't helping any." }
       created_at Time.now
       updated_at Time.now
    end
end
