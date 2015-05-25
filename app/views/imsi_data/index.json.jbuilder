json.array!(@imsi_data) do |imsi_datum|
  json.extract! imsi_datum, :id, :aimsicd_thread_level
  json.url imsi_datum_url(imsi_datum, format: :json)
end
