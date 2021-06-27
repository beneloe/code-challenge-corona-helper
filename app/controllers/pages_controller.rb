require 'open-uri'
require 'nokogiri'

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  class Physician
    attr_reader :name, :specialty, :address, :number

    def initialize(name, specialty, address, number)
      @name = name
      @specialty = specialty
      @address = address
      @number = number
    end
  end

  class Counsellor
    attr_reader :name, :specialty, :address, :number

    def initialize(name, specialty, address, number)
      @name = name
      @specialty = specialty
      @address = address
      @number = number
    end
  end

  def home
    @search = search_params
    if @search.present?
      @address = @search["address"].split(",")[0]
      unless @address.empty?
        html_content_physicians = URI.open("https://www.gelbeseiten.de/Suche/kinderarzt/#{@address}?umkreis=20000").read
        doc_physicians = Nokogiri::HTML(html_content_physicians)
        physicians = doc_physicians.css('article.mod.mod-Treffer')
        @physicians_array = []
        physicians.each do |physician|
          name = physician.css('a h2').text
          physician.css('p.d-inline-block.mod-Treffer--besteBranche').text.include?("Jugendmedizin") ? specialty = "Pediatrician" : nil
          address = physician.css('address.mod.mod-AdresseKompakt>p').first.text
          number = physician.css('p.mod-AdresseKompakt__phoneNumber').text
          @physicians_array << Physician.new(name, specialty, address, number)
        end
      end
    end

    if @search.present?
      @address = @search["address"].split(",")[0]
      unless @address.empty?
        html_content_counsellors = URI.open("https://www.gelbeseiten.de/Suche/Jugendaemter/#{@address}?umkreis=20000").read
        doc_counsellors = Nokogiri::HTML(html_content_counsellors)
        counsellors = doc_counsellors.css('article.mod.mod-Treffer')
        @counsellors_array = []
        counsellors.each do |counsellor|
          name = counsellor.css('a h2').text
          counsellor.css('p.d-inline-block.mod-Treffer--besteBranche').text.include?("Jugend") ? specialty = "Youth Counsellor" : nil
          address = counsellor.css('address.mod.mod-AdresseKompakt>p').first.text
          number = counsellor.css('p.mod-AdresseKompakt__phoneNumber').text
          @counsellors_array << Counsellor.new(name, specialty, address, number)
        end
      end
    end
  end

  private

  def search_params
    params[:search]
  end
end
