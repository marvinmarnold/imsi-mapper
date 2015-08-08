# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'csv'

@bSeeding = StingrayReading::Flags::SEEDING 
gps = CSV.foreach('db/gps.csv', {:headers => true, :col_sep => ","}) do |row|
    
  STDERR.puts "Processing #{row}"
  @stingray_reading = StingrayReading.new(flag: @bSeeding, version: "1", lat: row[0], long: row[1], threat_level: 0, observed_at: Time.now)
  if @stingray_reading.set_location() 
    @stingray_reading.flag = 0 # clear our seeding flag, so updating this entry later follows correct logic  
    @stingray_reading.save()
  end
  
  # note, can only process 2500 over 24 hour period
  sleep(0.2) # to avoid overloading the geocode api, throttle to 5 req/second
  #break
end