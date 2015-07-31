# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'csv'
gps = CSV.foreach('db/gps_test.csv', {:headers => true, :col_sep => ","}) do |row|
  StingrayReading.create(version: "1", lat: row[0], long: row[1], threat_level: 0, observed_at: Time.now)
end

