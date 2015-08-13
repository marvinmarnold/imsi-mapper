# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'csv'

StingrayReading.delete_all

gps = CSV.foreach('db/gps.csv', {:headers => true, :col_sep => ","}) do |row|
    
  STDERR.puts "Processing #{row}"
  iThreatLevel = rand(0..15)
  @stingray_reading = StingrayReading.new( version: "1", lat: row[0], long: row[1], threat_level: iThreatLevel, observed_at: Time.now)
  @stingray_reading.seeding= true
  @stingray_reading.prepopulated= true
  
  # STDERR.puts @stingray_reading.inspect
  
  if @stingray_reading.reverseGeocode 
    @stingray_reading.save()
    # STDERR.puts "#{row[0]}, #{row[1]}"
  end
  
end