class VoyageController < ApplicationController
  # require all routes of the voyage controller to be logged in to an account
  before_action :check_logged_in
  def new
    if @voyage != nil
      render json: { "error": "This user already has an active voyage!" }
      return
    end
    data = {
      "name": params["name"]
    }
    voyage = Voyage.new(data)
    voyage.save!

    # set user's voyage to this voyage!
    @user.voyage = voyage.id
    @user.save!
    session[:user_id] = @user

    render json: { "hi": "there" }
  end

  private
    def check_logged_in
      loggedin = session[:user_id] != nil and session[:user_id]["uid"] != nil
      if not loggedin
        redirect_to root_path
      end
      @user = User.find(session[:user_id]["id"])
      if @user.voyage != nil
        @voyage = Voyage.find(@user.voyage)
      end
    end
end
