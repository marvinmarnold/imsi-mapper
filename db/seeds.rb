# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'csv'

if(StingrayReading.all.size == 0)
  CSV.foreach('db/gps.csv', {:headers => true, :col_sep => ","}) do |row|
    danger_threat_level = rand(15..20)
    @stingray_reading = StingrayReading.new( version: "1", lat: row[0], long: row[1], threat_level: danger_threat_level, observed_at: Time.now)
    @stingray_reading.prepopulated= true

    if @stingray_reading.reverse_geocode
      @stingray_reading.save
    end

  end
end

CSV.foreach('db/factoids.csv', {:headers => true, :col_sep => ","}) do |row|
  Factoid.create(fact: row[0])
end