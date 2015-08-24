class ApplicationController < ActionController::API
    include ActionController::Serialization
    include ActionController::HttpAuthentication::Token::ControllerMethods
    @bAuthorized = false #placeholder

    before_action :set_authorized

    private

        # Let everyone into the API, but set bIsAuthorized to true for those who
        # have a valid token. We test for this when choosing whether to return
        # high resolution lat/long or not
        #
        # from: http://railscasts.com/episodes/352-securing-an-api
        # curl https://stinger-api-vannm.c9.io/stingray_readings/1 -H 'Authorization: Token token="d274fe1504b0c510a87cb1f6dc952e96"'
        # to generate a token, from commandline:
        # rails c
        # > ApiKey.create!
        def set_authorized
          authenticate_with_http_token do |t, o|
            @bIsAuthorized = ApiKey.exists?(access_token: t)
          end
        end
end
