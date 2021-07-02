require 'open-uri'
require 'nokogiri'

class CounsellorsController < ApplicationController
  def index
    if params[:address].present?
      @counsellors = Counsellor.all
    end
  end

  def new
    @counsellor = Counsellor.new
  end

  def create

    @search = @address_search
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
            Counsellor.new(name, specialty, address, number)
          end
        end
      end
    end

    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end

  private

  def counsellor_params
    params.require(:counsellor).permit(:name, :specialty, :address, :number)
  end
end
