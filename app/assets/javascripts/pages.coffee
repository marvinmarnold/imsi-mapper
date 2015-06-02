# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready ->
	L.mapbox.accessToken = 'pk.eyJ1IjoidW5wbHVnZ2VkIiwiYSI6IjNlYzFmM2YwZDYzYTM0ZjE5YzYyOGY1OWViM2Q0ODRhIn0.goeHIOasI8pdQeUSY0_Z3Q';
	map = L.mapbox.map('map', 'mapbox.streets').setView([29.94228045, -90.07880318], 14);
	geojson = []

	$.ajax
		dataType: 'text'
		url: 'imsi_data.json'
		success: (data) ->
			geojson = geojson.concat($.parseJSON(data))
			map.featureLayer.setGeoJSON(geojson)

	$.ajax
		dataType: 'text'
		url: 'wifi_data.json'
		success: (data) ->
			geojson = geojson.concat($.parseJSON(data))
			map.featureLayer.setGeoJSON(geojson)

	map.featureLayer.on 'layeradd', (e) ->
		marker = e.layer
		properties = marker.feature.properties

		popupContent = '<div class="popup">' +
										'<h3>' + properties.name + '</h3>' +
									'</div>'
		marker.bindPopup popupContent,
			closeButton: false
			minWidth: 320