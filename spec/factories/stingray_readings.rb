FactoryGirl.define do
  factory :stingray_reading do
    version "1"
    lat      { rand(29.4..49.3) }
    long     { rand(-97.3..-89.1) }
    threat_level { rand(15..20) }
    observed_at Time.now
    unique_token "aorisntoraisentoiraetsnraiosetn"

    factory :dangerous_stingray_reading do
    end

    factory :safe_stingray_reading do
      threat_level { rand(0..14) }
    end

    factory :inconsistent_stingray_reading do
      location "A test place"
    end
  end
end