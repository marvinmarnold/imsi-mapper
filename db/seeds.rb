# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'csv'

gps = CSV.foreach('db/gps.csv', {:headers => true, :col_sep => ","}) do |row|
    
  STDERR.puts "Processing #{row}"
  @stingray_reading = StingrayReading.new( version: "1", lat: row[0], long: row[1], threat_level: 0, observed_at: Time.now)
  @stingray_reading.seeding= true
  @stingray_reading.prepopulated= true
  if @stingray_reading.set_location() 
    @stingray_reading.seeding= false # clear our seeding flag, we're done doing that
    @stingray_reading.save()
  else
    STDERR.puts "no location value. skipping"
  end
  sleep(0.2) # to avoid overloading google's geocode api, throttle to 5 req/second
  #break
end