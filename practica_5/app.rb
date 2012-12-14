# coding: utf-8
require 'sinatra'
require 'json'
set server: 'thin', users: {}

class String
  def sanitize
    self.gsub(/\W/,'')
  end
end

get '/' do
  halt erb(:login) unless params[:user]
  erb :chat, locals: { user: params[:user].sanitize }
end

get '/check/:user' do #Check if :name is already taken
   settings.users.keys.include?(params[:user].sanitize)  == true ?  JSON.generate({:error => "Name already taken"}) : JSON.generate({:success => "Welcome aboard!"})
end

get '/stream/:user', provides: 'text/event-stream' do
  stream :keep_open do |out|
    out << "data: #{JSON.generate({:users => settings.users.keys})}\n\n" #Send all users list to the new user
    settings.users.values.each { |out| out << "data: #{JSON.generate({:joined => params[:user]})}\n\n" } #Notify the user joined to other users
    settings.users[params[:user]] = out #Save new user's connection
    out.callback { 
      name = settings.users.key out
      settings.users.delete name
      settings.users.values.each { |out| out << "data: #{JSON.generate({:left => name})}\n\n" } #Notify the user left to other users
    }
  end
end

post '/' do
  to = /\/(.+):(.*)/.match(params[:msg])
  to,msg = to[1], to[2] unless to.nil?
  if (defined? to) and (out = settings.users[to]) != nil
    out << "data: #{JSON.generate({:message => msg, :user => params[:user], :private => true})}\n\n"    
  else
    settings.users.values.each { |out| out << "data: #{JSON.generate({:message => params[:msg], :user => params[:user]})}\n\n" } #Broadcast message
  end
  204 # response without entity body
end