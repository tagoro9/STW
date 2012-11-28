require 'sinatra'
require 'sinatra/activerecord'
require 'haml'
require 'xmlsimple'
require 'rest_client'
set :database, 'sqlite3:///shortened_urls.db'
set :address, 'localhost:4567'
#set :address, 'exthost.etsii.ull.es:4567'

class ShortenedUrl < ActiveRecord::Base
  # Validates whether the value of the specified attributes are unique across the system.
  validates_uniqueness_of :url, :personalUrl
  # Validates that the specified attributes are not blank
  validates_presence_of :url
  #validates_format_of :url, :with => /.*/
  validates_format_of :url, 
       :with => %r{^(https?|ftp)://.+}i, 
       :allow_blank => true, 
       :message => "The URL must start with http://, https://, or ftp:// ."
end
class Paises < ActiveRecord::Base
  #Validar de manera unica la pareja url pais.
  validates_uniqueness_of :url, :scope => :pais
end

get '/' do
  haml :index
end

post '/' do
  if params[:urlP].empty?
    @short_url = ShortenedUrl.find_or_create_by_url(params[:url])
    if @short_url.valid?
      haml :success, :locals => { :address => settings.address }
    else
      haml :index
    end
  else
    urlP = ShortenedUrl.find_or_create_by_url_and_personalUrl(params[:url],params[:urlP])
    if urlP.valid?
      haml :success1, :locals => { :address => urlP.url,
                                    :address1 => urlP.personalUrl,
                                    :settings => settings.address }
    else
      haml :index
    end
  end
end

get '/listar' do
  lista = ShortenedUrl.find(:all)
  haml :list, :locals => { :lista => lista,
                           :settings => settings.address}
    
end

get '/visitas' do
  lista = Paises.find(:all)
  total = 0
  haml :visitas, :locals => { :lista => lista,
                              :total => total}
end

post '/BAbreviacion' do
  abreviatura = ShortenedUrl.find_by_id(params[:url].to_i(36))
  if abreviatura.present?
    haml :mostrar, :locals => { :address => abreviatura.url }
  else
    haml :index
  end
end

post '/BUrl' do
  urlorigen = ShortenedUrl.find_by_url(params[:url])
  if urlorigen.present?
    haml :mostrar, :locals => { :address => "#{settings.address}/#{urlorigen.id.to_s(36)}"}
  else
    haml :index
  end
end

get '/:shortened' do
  short_url = ShortenedUrl.find_by_personalUrl(params[:shortened])
  if short_url.nil?
    short_url = ShortenedUrl.find(params[:shortened].to_i(36))
  end
  siglasPais = RestClient.get "http://api.hostip.info/country.php"
  @UrlPais = Paises.find_or_create_by_url_and_pais(short_url.url, siglasPais)
  @UrlPais.visitas = @UrlPais.visitas + 1
  @UrlPais.save
  redirect short_url.url
end