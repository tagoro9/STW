require 'sinatra'
require 'sinatra/activerecord'
require 'haml'
require 'xmlsimple'
require 'rest_client'

set :database, 'sqlite3:///shortened_urls.db'
set :address, 'localhost:4567'


class ShortenedUrl < ActiveRecord::Base
  # Validates whether the value of the specified attributes are unique across the system.
  validates_uniqueness_of :url
  # Validates that the specified attributes are not blank
  validates_presence_of :url
  #validates_format_of :url, :with => /.*/
  validates_format_of :url, 
       :with => %r{^(https?|ftp)://.+}i, 
       :allow_blank => true, 
       :message => "The URL must start with http://, https://, or ftp:// ."
end

class Paises < ActiveRecord::Base
  # Validates whether the value of the specified attributes are unique across the system.
  validates_uniqueness_of :url, :scope => :pais
end



get '/' do
  haml :index
end

post '/' do
  if params[:custom].empty?
	  @short_url = ShortenedUrl.find_or_create_by_url(params[:url])
	  if @short_url.valid?
	    haml :success, :locals => { :address => settings.address }
	  else
	    haml :index
	  end
  else
    urlP = @short_url = ShortenedUrl.find_or_create_by_url :url => params[:url], :custom => params[:custom]
    if urlP.valid?
	    haml :success, :locals => { :address => settings.address }
    else
	    haml :index
    end

  end
end


get '/show' do
  @urls = ShortenedUrl.find(:all)
  haml :show
end


post '/BuscarID' do
 @url = ShortenedUrl.find_by_id(params[:url].to_i(36))

  haml :show2
end

post '/BuscarURL' do
  @url = ShortenedUrl.find_by_url(params[:url])
  haml :show2
end



get '/:shortened' do
  short_url ||= ShortenedUrl.find_by_id(params[:shortened].to_i(36))
  short_url ||= ShortenedUrl.find_by_custom(params[:shortened])

  xml = RestClient.get "http://api.hostip.info/get_xml.php?ip=#{request.ip}"
  sPais = XmlSimple.xml_in(xml.to_s, { 'ForceArray' => false })['featureMember']['Hostip']['countryAbbrev']
  @UPais = Paises.find_or_create_by_url_and_pais(short_url.url, sPais)
  @UPais.visitas =+ 1
  @UPais.save
  redirect short_url.url
end

