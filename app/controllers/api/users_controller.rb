module Api
  class UsersController < ApiController
    before_action :authenticate_api_user!

    def show
      render json: current_api_user
    end
  end
end
