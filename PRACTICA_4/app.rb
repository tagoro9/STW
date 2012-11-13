require 'sinatra'
require 'sinatra/activerecord'
require 'haml'

set :database, 'sqlite3:///shortened_urls.db'
set :address, 'localhost:4567'
#set :address, 'exthost.etsii.ull.es:4567'

class ShortenedUrl < ActiveRecord::Base
  # Validates whether the value of the specified attributes are unique across the system.
  validates_uniqueness_of :url
  validates_uniqueness_of :custom, :allow_blank => true
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
  @short_url = ShortenedUrl.find_or_create_by_url_and_custom(params[:url],params[:custom])
  if @short_url.valid?
    @short_url.custom = @short_url.id.to_s(36) if @short_url.custom.empty?
    @short_url.save
    haml :success, :locals => { :address => settings.address,
                                :url => @short_url }
  else
    haml :index
  end
end

get '/list' do
  urls = ShortenedUrl.find(:all)
  haml :list, :locals => { :urls => urls,
                           :address => settings.address }
end

post '/searchid' do
  @short_url = ShortenedUrl.find_by_id(params[:id].to_i(36))
  if @short_url.present?
    haml :search, :locals => { :address => settings.address,
                               :short_url => @short_url }
  else
    haml :index
  end 
end

post '/searchurl' do
  @short_url = ShortenedUrl.find_by_url(params[:url])
  if @short_url.present?
    haml :search, :locals => { :address => settings.address,
                               :short_url => @short_url }
  else
    haml :index
  end 
end

get '/:shortened' do
  short_url = ShortenedUrl.find_by_custom(params[:shortened])
  begin
    redirect short_url.url
  rescue
    short_url = ShortenedUrl.find(params[:shortened].to_i(36))
    redirect short_url.url
  end
end
