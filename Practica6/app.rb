# coding: utf-8
require 'sinatra'
set server: 'thin', connections: Hash.new

get '/' do
  halt erb(:login) unless params[:user]
  erb :chat, locals: { user: params[:user].gsub(/\W/, '') }
end

get '/stream/:user', provides: 'text/event-stream' do
  stream :keep_open do |out|
    settings.connections[params[:user]] = out
    out.callback { settings.connections.delete params[:user] }
  end
end

post '/' do
  nikname_expr = /\/(.+):.*/
  user = nikname_expr.match(params[:msg])
  if user.nil?
    settings.connections.each_pair { |user, out| out << "data: #{params[:user]} : #{params[:msg]}\n\n" }
    204 # response without entity body
  else
    settings.connections[user[1]] << "data: Mensaje Privado de #{params[:user]} : #{params[:msg].gsub(/\/(.+):/, '')}\n\n"
    settings.connections[params[:user]] << "data: Mensaje Privado para #{user[1]} : #{params[:msg].gsub(/\/(.+):/, '')}\n\n"
    204 # response without entity body
  end
end