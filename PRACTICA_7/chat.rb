# coding: utf-8
require 'sinatra'
set server: 'thin', users: {}

get '/' do
  halt erb(:login) unless params[:user]
  erb :chat, locals: { user: params[:user].gsub(/\W/, '') }
end

get '/stream/:user', provides: 'text/event-stream' do
  stream :keep_open do |out|
    settings.users[params[:user]] = out
    data = []
    data[0] = "#{params[:user]} entered the room</br>"
    data[1] = settings.users.keys
    data[2] = params[:user]
    data[3] = "inOut"
    settings.users.values.each { |out| out << "data: #{data}\n\n"}
    204 # response without entity body

    out.callback do
      user = settings.users.key out
      settings.users.delete user
      data = []
      data[0] = "#{user} left the room</br>"
      data[1] = settings.users.keys
      data[2] = "#{user}"
      data[3] = "inOut"
      settings.users.values.each { |out| out << "data: #{data}\n\n"}
    end

    # out.errback do
    #   logger.warn 'we just lost the connection!'
    #   settings.users.delete(out)
    # end
  end
end

post '/' do
  pm = /\/(.+):(.*)/.match(params[:msg])
  receiver, msg = pm[1], pm[2] unless pm.nil?
  data = []
  data[2] = params[:user]
  data[1] = settings.users.keys
  if pm.nil?  # broadcast
    data[3] = "broadcast"
    data[0] = "#{params[:user]}: #{params[:msg]}</br>"
    settings.users.values.each { |out| out << "data: #{data}\n\n"}

  elsif settings.users.has_key? receiver  # private message
    data[3] = "private"
    data[0] = "PM from #{params[:user]}: <i>#{msg}</i></br>"
    settings.users[receiver] << "data: #{data}\n\n"
    data[0] = "PM to #{receiver}: <i>#{msg}</i></br>"
    settings.users[params[:user]] << "data: #{data}\n\n"

  else
    data[3] = "invalid"
    data[0] = "No user with such nickname!"
    settings.users[params[:user]] << "data: #{data}\n\n"
  end
  204 # response without entity body
end
