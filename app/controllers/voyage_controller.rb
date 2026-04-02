class VoyageController < ApplicationController
  def new
    data = {
      "name": params["name"]
    }
    voyage = Voyage.new(data)
    render json: { "hi": "there" }
  end
end
