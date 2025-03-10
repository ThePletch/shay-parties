class AddressesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_owned_address, only: [:show]


  def show
  end

  private

  def set_owned_address
    @address = current_user.addresses.find(params[:id].to_i)
  end
end
