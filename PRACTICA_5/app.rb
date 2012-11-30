require 'sinatra'
require 'sinatra/activerecord'
require 'haml'
require 'xmlsimple'
require 'rest_client'

set :database, 'sqlite3:///shortened_urls.db'
#set :address, 'localhost:4567'
set :address, 'exthost.etsii.ull.es:4567'

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

class Countries < ActiveRecord::Base
  #Validar de manera unica la pareja url pais.
  validates_uniqueness_of :url, :scope => :country
end


get '/' do
  haml :index
end

get '/show' do
  @urls = ShortenedUrl.find :all
  haml :show
end

get '/stats' do
  @countries_list = Countries.find :all
  haml :stats
end

post '/' do
  if params[:custom].present?
    @short_url = ShortenedUrl.find_or_create_by_url :url => params[:url], :custom => params[:custom]
  else
    @short_url = ShortenedUrl.find_or_create_by_url(params[:url])
  end
  if @short_url.valid?
    haml :success, :locals => { :address => settings.address }  
  else
    haml :index
  end
end

post '/search' do
  @url_found = ShortenedUrl.find_by_url params[:search]
  @abv_found = ShortenedUrl.find_by_id params[:search].to_i(36)
  haml :search
end

get '/:shortened' do
  short_url ||= ShortenedUrl.find_by_id(params[:shortened].to_i(36))
  short_url ||= ShortenedUrl.find_by_custom(params[:shortened])
  xml = RestClient.get  "http://api.hostip.info/get_xml.php?ip=#{request.ip}"
  country_name = XmlSimple.xml_in(xml.to_s, { 'ForceArray' => false })['featureMember']['Hostip']['countryAbbrev']
  @CountryURL = Countries.find_or_create_by_url_and_country(short_url.url, country_name)
  @CountryURL.visits = @CountryURL.visits + 1
  @CountryURL.save
  redirect short_url.url
end


