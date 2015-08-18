

FactoryGirl.define do
    
    factory :stingray_reading do
   
        version "1" 
        lat      { rand(29.4..49.3) }
        long     { rand(-97.3..-89.1) }
        threat_level { rand(15..20) }
        observed_at Time.now
    
    end
    
end