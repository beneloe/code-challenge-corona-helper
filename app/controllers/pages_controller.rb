require 'open-uri'
require 'nokogiri'

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
    html_content = URI.open('https://www.doctolib.de/kinderheilkunde-kinder-und-jugendmedizin/berlin').read
    @doc = Nokogiri::HTML(html_content)
  end
end
