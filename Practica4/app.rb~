require 'sinatra'
require 'sinatra/activerecord'
require 'haml'

set :database, 'sqlite3:///shortened_urls.db'
set :address, 'localhost:4567'
#set :address, 'exthost.etsii.ull.es:4567'

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


get '/' do
  haml :index
end

post '/' do
  @short_url = ShortenedUrl.find_or_create_by_url(params[:url])
  if @short_url.valid?
    haml :success, :locals => { :address => settings.address }
  else
    haml :index
  end
end

get '/listar' do
  lista = ShortenedUrl.find(:all)
  haml :list, :locals => { :lista => lista,
                           :settings => settings.address}
    
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
    haml :mostrar, :locals => { :address => "#{settings.address}/#{urlorigen.id}"}
  else
    haml :index
  end
end

get '/:shortened' do
  short_url = ShortenedUrl.find(params[:shortened].to_i(36))
  redirect short_url.url
end