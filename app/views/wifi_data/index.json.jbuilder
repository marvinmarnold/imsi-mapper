json.array!(@wifi_data) do |wifi_datum|
  json.extract! wifi_datum, :id, :num_wifi_hotspots, :latitude_degrees, :longitude_degrees
  json.url wifi_datum_url(wifi_datum, format: :json)
end
