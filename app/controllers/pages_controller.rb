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
    begin
      @physicians_array = []
      @search = search_params
      if @search.present?
        @address_real = @search["address"].split(",")[0]
        @address = @search["address"].split(",")[0].gsub(" ", "%20").gsub("ü", "ue").gsub("ä", "ae").gsub("ö", "oe")
        unless @address.empty?
          @url_physicians = "https://www.gelbeseiten.de/Suche/kinderarzt/#{@address}?umkreis=20000"
          html_content_physicians = URI.open(@url_physicians).read
          doc_physicians = Nokogiri::HTML(html_content_physicians)
          @all_physicians = doc_physicians.css('head').text.include?("Bundesweit")
          @num_physicians = doc_physicians.css('h1.mod.mod-TrefferlisteInfo').first.text.split.first
          physicians = doc_physicians.css('article.mod.mod-Treffer')
          physicians.each do |physician|
            name = physician.css('h2').text
            physician.css('p.d-inline-block.mod-Treffer--besteBranche').text.include?("Jugendmedizin") ? specialty = "Pediatrician" : nil
            address = physician.css('address.mod.mod-AdresseKompakt>p').first.text.tap { |s| s.slice!(physician.css('span.mod-AdresseKompakt__entfernung').text.to_s) }
            number = physician.css('p.mod-AdresseKompakt__phoneNumber').text
            unless specialty.nil?
              @physicians_array << Physician.new(name, specialty, address, number)
            end
          end
        end
      end

      @counsellors_array = []
      if @search.present?
        @address_real = @search["address"].split(",")[0]
        @address = @search["address"].split(",")[0].gsub(" ", "%20").gsub("ü", "ue").gsub("ä", "ae").gsub("ö", "oe")
        unless @address.empty?
          @url_counsellors = "https://www.gelbeseiten.de/Suche/Jugendaemter/#{@address}?umkreis=20000"
          html_content_counsellors = URI.open(@url_counsellors).read
          doc_counsellors = Nokogiri::HTML(html_content_counsellors)
          @num_counsellors = doc_counsellors.css('h1.mod.mod-TrefferlisteInfo').first.text.split.first
          counsellors = doc_counsellors.css('article.mod.mod-Treffer')
          counsellors.each do |counsellor|
            name = counsellor.css('h2').text
            counsellor.css('p.d-inline-block.mod-Treffer--besteBranche').text.include?("Jugendämter") ? specialty = "Youth Counsellor" : nil
            address = counsellor.css('address.mod.mod-AdresseKompakt>p').first.text.tap { |s| s.slice!(counsellor.css('span.mod-AdresseKompakt__entfernung').text.to_s) }
            number = counsellor.css('p.mod-AdresseKompakt__phoneNumber').text
            unless specialty.nil?
              @counsellors_array << Counsellor.new(name, specialty, address, number)
            end
          end
        end
      end
    rescue StandardError => e
      puts "error"
    end
    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end

  private

  def search_params
    params[:search]
  end
end
