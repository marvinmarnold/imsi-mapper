class MockController < ApplicationController
    
    
    def index
    end
    
    def show
    end
    
    # emulate a google geocode timeout response
    def create
        
        sText = %{<?xml version="1.0" encoding="UTF-8"?>
            <GeocodeResponse>
             <status>OVER_QUERY_LIMIT</status>
            <error_message>You have exceeded your rate-limit for this API.</error_message>
            </GeocodeResponse>}
        
        render text: sText
        
    end
      
    


end
