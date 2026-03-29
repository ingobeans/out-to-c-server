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
            redirect_to root_path, notice: "Missing authentication code"
            return
        end

        # exchange code for token
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

        puts res.body

        token = ""

        # whether the authentication was unsuccesful
        error = (not (res.kind_of? Net::HTTPSuccess)) or res.body.include? "error"

        if not error
            data = JSON.parse(res.body)

            if data == nil or data["access_token"] == nil
                # mark authentication as unsuccesful
                error = true
            else
                token = data["access_token"]
            end
        end

        if error
            redirect_to root_path, notice: "Invalid authentication code or authentication server was unreachable"
            return
        end

        redirect_to root_path, notice: "token:"+token
    end
end
