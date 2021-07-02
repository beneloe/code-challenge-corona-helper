require 'open-uri'
require 'nokogiri'

class PhysiciansController < ApplicationController
  skip_before_action :authenticate_user!, only: [:create]
  def index
    if params[:address].present?
      @physicians = Physician.all
    end
  end

  def new
    @physician = Physician.new
  end

  def create
    @physicians_array = []
    @search = params[:address]
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
            @physicians_array << Physician.new({name: name, specialty: specialty, address: address, number: number})
          end
        end
        if @physicians_array.length > 0
          render 'physician'
        else
          redirect_to root_path
        end
      end
    end

    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end
end
