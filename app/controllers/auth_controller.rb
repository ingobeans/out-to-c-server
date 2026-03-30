require "net/http"

class AuthController < ApplicationController
    def callback
        error = params["error"]
        if error != nil
            msg = "Error: "+error
            if error == "access_denied"
                msg = "Canceled login"
            end
            redirect_to root_path, notice: msg
            return
        end
        code = params["code"]
        if code == nil || code.blank?
            redirect_to root_path, notice: "error: Missing authentication code"
            return
        end

        # exchange code for token
        response = getToken(code)

        if response[:token] == nil
            redirect_to root_path, notice: "error: Couldn't get token: " + response[:error].to_s
            return
        end
        token = response[:token]

        redirect_to root_path, notice: "token:"+token
    end

    private
        # exchange a authentication code for a hackatime user token
        def getToken(code)
            uri = URI.parse("https://hackatime.hackclub.com/oauth/token")
            data = '{
                "client_id": "'+ ENV["HACKATIME_UID"]+ '",
                "client_secret": "'+ ENV["HACKATIME_SECRET"]+ '",
                "redirect_uri": "' + url_for(only_path: false) + '",
                "code": "' + params["code"] + '",
                "grant_type": "authorization_code"
            }'
            headers = { 'content-type': "application/json" }
            res = Net::HTTP.post(uri, data, headers)

            # whether the authentication was unsuccesful
            error = (not (res.kind_of? Net::HTTPSuccess)) or res.body.include? "error"

            if error
                { "error": "Error from hackatime API" }
            else
                data = JSON.parse(res.body)
                if data == nil or data["access_token"] == nil
                    { "error": "Bad response from hackatime API" }
                else
                    { "token": data["access_token"] }
                end
            end
        end
end
