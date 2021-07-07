class HelpersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :create]

  def index
    # begin
    @first_value = session[:passed_variable]
    @search = @first_value
    @url_physicians = "https://www.gelbeseiten.de/Suche/kinderarzt/#{@address}?umkreis=20000"
    html_content_physicians = URI.open(@url_physicians).read
    doc_physicians = Nokogiri::HTML(html_content_physicians)
    @all_physicians = doc_physicians.css('head').text.include?("Bundesweit")
    @physicians_array = []
    @counsellors_array = []
    @markers = []
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
        physicians[0...5].each do |physician|
          name = physician.css('h2').text
          physician.css('p.d-inline-block.mod-Treffer--besteBranche').text.include?("Jugendmedizin") ? specialty = "Pediatrician" : nil
          address = (physician.css('address.mod.mod-AdresseKompakt>p').first.text.tap { |s| s.slice!(physician.css('span.mod-AdresseKompakt__entfernung').text.to_s) }).gsub(/\R+/, ' ').gsub(/[^[:print:]]/, '')
          number = physician.css('p.mod-AdresseKompakt__phoneNumber').text
          
          uri = URI('http://api.positionstack.com/v1/forward')

          params = {
              'access_key' => '0f3ddc4ca8fa40c5b6edc0e694a649e3',
              'query' => "#{address}",
              'country' => 'DE',
              'limit' => 1
          }

          uri.query = URI.encode_www_form(params)

          response = Net::HTTP.get_response(uri)
          parsed_response = JSON.parse(response.body)
          if parsed_response['data'].empty?
            latitude = nil
            longitude = nil
          elsif !parsed_response['data'][0].empty?
            latitude = parsed_response['data'][0]['latitude']
            longitude = parsed_response['data'][0]['longitude']
          elsif parsed_response['data'][0].empty?
            latitude = nil
            longitude = nil
          end

          unless specialty.nil?
            physician_new = Helper.new({name: name, specialty: specialty, address: address, number: number, latitude: latitude, longitude: longitude})
            @physicians_array << physician_new
            @markers << { lat: physician_new.latitude, lng: physician_new.longitude, info_window: render_to_string(partial: "info_window", locals: { helper: physician_new }) }
          end
        end
        @url_counsellors = "https://www.gelbeseiten.de/Suche/Jugendaemter/#{@address}?umkreis=20000"
        html_content_counsellors = URI.open(@url_counsellors).read
        doc_counsellors = Nokogiri::HTML(html_content_counsellors)
        @num_counsellors = doc_counsellors.css('h1.mod.mod-TrefferlisteInfo').first.text.split.first
        counsellors = doc_counsellors.css('article.mod.mod-Treffer')
        counsellors[0...5].each do |counsellor|
          name = counsellor.css('h2').text
          counsellor.css('p.d-inline-block.mod-Treffer--besteBranche').text.include?("Jugendämter") ? specialty = "Youth Counsellor" : nil
          address = (counsellor.css('address.mod.mod-AdresseKompakt>p').first.text.tap { |s| s.slice!(counsellor.css('span.mod-AdresseKompakt__entfernung').text.to_s) }).gsub(/\R+/, ' ').gsub(/[^[:print:]]/, '')
          number = counsellor.css('p.mod-AdresseKompakt__phoneNumber').text
          
          uri = URI('http://api.positionstack.com/v1/forward')
          
          params = {
              'access_key' => '0f3ddc4ca8fa40c5b6edc0e694a649e3',
              'query' => "#{address}",
              'country' => 'DE',
              'limit' => 1
          }
          
          uri.query = URI.encode_www_form(params)
          
          response = Net::HTTP.get_response(uri)
          parsed_response = JSON.parse(response.body)
          if parsed_response['data'].empty?
            latitude = nil
            longitude = nil
          elsif !parsed_response['data'][0].empty?
            latitude = parsed_response['data'][0]['latitude']
            longitude = parsed_response['data'][0]['longitude']
          elsif parsed_response['data'][0].empty?
            latitude = nil
            longitude = nil
          end
          
          unless specialty.nil?
            counsellor_new = Helper.new({name: name, specialty: specialty, address: address, number: number, latitude: latitude, longitude: longitude})
            @counsellors_array << counsellor_new
            @markers << { lat: counsellor_new.latitude, lng: counsellor_new.longitude, info_window: render_to_string(partial: "info_window", locals: { helper: counsellor_new }) }
          end
        end
      end
    end
    # rescue StandardError => e
    #   puts "error"
    # end
  end

  def create
    # begin
    @physicians_array = []
    @counsellors_array = []
    @markers = []
    @search = params[:address]
    @first_value = params[:address]
    session[:passed_variable] = @first_value
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
        physicians[0...5].each do |physician|
          name = physician.css('h2').text
          physician.css('p.d-inline-block.mod-Treffer--besteBranche').text.include?("Jugendmedizin") ? specialty = "Pediatrician" : nil
          address = (physician.css('address.mod.mod-AdresseKompakt>p').first.text.tap { |s| s.slice!(physician.css('span.mod-AdresseKompakt__entfernung').text.to_s) }).gsub(/\R+/, ' ').gsub(/[^[:print:]]/, '')
          number = physician.css('p.mod-AdresseKompakt__phoneNumber').text
          
          uri = URI('http://api.positionstack.com/v1/forward')

          params = {
              'access_key' => '0f3ddc4ca8fa40c5b6edc0e694a649e3',
              'query' => "#{address}",
              'country' => 'DE',
              'limit' => 1
          }

          uri.query = URI.encode_www_form(params)

          response = Net::HTTP.get_response(uri)
          parsed_response = JSON.parse(response.body)
          if parsed_response['data'].empty?
            latitude = nil
            longitude = nil
          elsif !parsed_response['data'][0].empty?
            latitude = parsed_response['data'][0]['latitude']
            longitude = parsed_response['data'][0]['longitude']
          elsif parsed_response['data'][0].empty?
            latitude = nil
            longitude = nil
          end

          unless specialty.nil?
            physician_new = Helper.new({name: name, specialty: specialty, address: address, number: number, latitude: latitude, longitude: longitude})
            @physicians_array << physician_new
            @markers << { lat: physician_new.latitude, lng: physician_new.longitude }
          end
        end
        @url_counsellors = "https://www.gelbeseiten.de/Suche/Jugendaemter/#{@address}?umkreis=20000"
        html_content_counsellors = URI.open(@url_counsellors).read
        doc_counsellors = Nokogiri::HTML(html_content_counsellors)
        @num_counsellors = doc_counsellors.css('h1.mod.mod-TrefferlisteInfo').first.text.split.first
        counsellors = doc_counsellors.css('article.mod.mod-Treffer')
        counsellors[0...5].each do |counsellor|
          name = counsellor.css('h2').text
          counsellor.css('p.d-inline-block.mod-Treffer--besteBranche').text.include?("Jugendämter") ? specialty = "Youth Counsellor" : nil
          address = (counsellor.css('address.mod.mod-AdresseKompakt>p').first.text.tap { |s| s.slice!(counsellor.css('span.mod-AdresseKompakt__entfernung').text.to_s) }).gsub(/\R+/, ' ').gsub(/[^[:print:]]/, '')
          number = counsellor.css('p.mod-AdresseKompakt__phoneNumber').text
          
          uri = URI('http://api.positionstack.com/v1/forward')
          
          params = {
              'access_key' => '0f3ddc4ca8fa40c5b6edc0e694a649e3',
              'query' => "#{address}",
              'country' => 'DE',
              'limit' => 1
          }
          
          uri.query = URI.encode_www_form(params)
          
          response = Net::HTTP.get_response(uri)
          parsed_response = JSON.parse(response.body)
          if parsed_response['data'].empty?
            latitude = nil
            longitude = nil
          elsif !parsed_response['data'][0].empty?
            latitude = parsed_response['data'][0]['latitude']
            longitude = parsed_response['data'][0]['longitude']
          elsif parsed_response['data'][0].empty?
            latitude = nil
            longitude = nil
          end
          
          unless specialty.nil?
            counsellor_new = Helper.new({name: name, specialty: specialty, address: address, number: number, latitude: latitude, longitude: longitude})
            @counsellors_array << counsellor_new
            @markers << { lat: counsellor_new.latitude, lng: counsellor_new.longitude }
          end
        end
        if @physicians_array.length > 0
          redirect_to '#info-2'
        else
          redirect_to '#info-2'
        end
      end
    end

    # rescue StandardError => e
    #   puts "error"
    # end
  end
end
