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
        redirect_to root_path
    end
end
