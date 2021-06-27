require 'open-uri'
require 'nokogiri'

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  class Physician
    attr_reader :name, :specialty, :address

    def initialize(name, specialty, address)
      @name = name
      @specialty = specialty
      @address = address
    end
  end

  def home
    @search = search_params
    if @search.present?
      @address = @search["address"].downcase.split(",")[0]
      unless @address.empty?
        html_content = URI.open("https://www.doctolib.de/kinderheilkunde-kinder-und-jugendmedizin/#{@address}").read
        doc = Nokogiri::HTML(html_content)
        entries = doc.css('.dl-search-result-presentation')
        @entries_array = []
        entries.each do |entry|
          name = entry.css('h3 a div').text
          specialty = entry.css('.dl-search-result-subtitle').text
          address = entry.css('.dl-text.dl-text-body.dl-text-s.dl-text-regular>div').text
          @entries_array << Physician.new(name, specialty, address)
        end
      end
    end
  end

  private

  def search_params
    params[:search]
  end
end
