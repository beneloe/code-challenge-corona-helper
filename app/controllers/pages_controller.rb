class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
    begin
    rescue StandardError => e
      puts "error"
    end
  end
end
