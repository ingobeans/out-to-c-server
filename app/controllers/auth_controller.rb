class AuthController < ApplicationController
    def callback
        code = params["code"]
        if code == nil || code.blank?
            redirect_to root_path, notice: "Missing authentication code"
            return
        end
        redirect_to root_path
    end
end
