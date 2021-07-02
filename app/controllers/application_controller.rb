class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  def save_address
    @address_search = params[:address]

    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end
end
