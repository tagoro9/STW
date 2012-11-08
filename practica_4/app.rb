require 'sinatra'
require 'sinatra/activerecord'
require 'haml'

set :database, 'sqlite3:///shortened_urls.db'
set :address, 'http://localhost:9393'

class ShortenedUrl < ActiveRecord::Base
  # Validates whether the value of the specified attributes are unique across the system.
  validates_uniqueness_of :url
  validates_uniqueness_of :custom, :allow_blank => true, :allow_nil => true, :message => "name has already been taken"
  # Validates that the specified attributes are not blank
  validates_presence_of :url
  #validates_format_of :url, :with => /.*/
  validates_format_of :url, 
       :with => %r{^(https?|ftp)://.+}i, 
       :allow_blank => true, 
       :message => "must start with http://, https://, or ftp:// ."
  def short_url
    "#{settings.address}/#{self.custom or self.id.to_s(36)}"
  end
  def self.create_or_update_by_url params
    current = self.find_by_url params[:url]
    if current.present?
      current.custom = params[:custom]
      current.save
      current
    else
      ShortenedUrl.create params
    end
  end
  def self.find_url url
    by_url = ShortenedUrl.find_by_url url
    match = url.scan(/:\/\/.*\/(.+)\/?$/)
    by_id = ShortenedUrl.find_by_id(match.first.first.to_i(36)) if !match.empty?
    by_custom = ShortenedUrl.find_by_custom(match.first.first) if !match.empty?
    by_url or by_id or by_custom 
  end
end

get '/' do 
	haml :index
end

post '/' do
  @short_url = if !params[:custom]
    ShortenedUrl.find_or_create_by_url params[:url]
  else
    ShortenedUrl.create_or_update_by_url :url => params[:url], :custom => params[:custom_name]
  end
  if @short_url.valid?
    haml :success
  else
    haml :index
  end
end

get '/list' do
	@shortened_urls = ShortenedUrl.find :all
	haml :list
end

post '/search' do
  @search_url = ShortenedUrl.find_url params[:search]
	haml :search
end

get '/:shortened' do
	long_url ||= ShortenedUrl.find_by_id params[:shortened].to_i(36)
  long_url ||= ShortenedUrl.find_by_custom params[:shortened]
	redirect long_url.url, 301
end