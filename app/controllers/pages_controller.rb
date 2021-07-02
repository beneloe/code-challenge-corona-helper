require 'open-uri'
require 'nokogiri'

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end
end
