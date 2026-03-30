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
        response = get_token(code)

        if response[:token] == nil
            redirect_to root_path, notice: "error: Couldn't get token: " + response[:error].to_s
            return
        end
        token = response[:token]

        user_data = get_user_data(token)
        slack_id = user_data["slack_id"]

        # check for existing user
        existing_user = User.where(uid: slack_id).first()
        if existing_user == nil
            # new user, fetch user data from slack
            slack_data = get_slack_data(slack_id)
            user_object = { "name": slack_data["displayName"], "pfp": slack_data["imageUrl"], "uid": slack_id, "token": token }
            user = User.create(user_object)
            user.save!
            session[:user_id] = user
            redirect_to root_path, notice: "welcome, new user named: "+user.name
        else
            # existing user
            session[:user_id] = existing_user
            redirect_to root_path, notice: "welcome back, user named:"+existing_user.name
        end
    end

    private
        def get_user_data(token)
            uri = URI.parse("https://hackatime.hackclub.com/api/v1/authenticated/me")
            req = Net::HTTP::Get.new(uri)
            req["Authorization"] = "Bearer " + token
            res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
                http.request(req)
            end

            JSON.parse(res.body)
        end

        def get_slack_data(slack_id)
            uri = URI.parse("https://cachet.dunkirk.sh/users/"+slack_id)
            req = Net::HTTP::Get.new(uri)
            res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
                http.request(req)
            end

            JSON.parse(res.body)
        end

        # exchange a authentication code for a hackatime user token
        def get_token(code)
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
