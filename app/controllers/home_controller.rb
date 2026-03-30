class HomeController < ApplicationController
    before_action :set_logged_in
    def index
    end

    private
        def set_logged_in
          @loggedin = session[:user_id] != nil and session[:user_id]["uid"] != nil
        end
end
