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
    out.callback {settings.connections.delete(settings.connections.key out) }
  end
end

post '/' do
  nikname_expr = /\/(.+):.*/
  user = nikname_expr.match(params[:msg])
  if user.nil?
    paso_datos = []
    paso_datos << "#{params[:user]} : #{params[:msg]}"
    settings.connections.keys.each{|key| paso_datos << key}
    settings.connections.each_pair { |user, out| out << "data: #{paso_datos} \n\n" }
    204 # response without entity body
  else
    paso_datos1 = []
    paso_datos2 = []
    paso_datos1 << "Mensaje Privado de #{params[:user]} : #{params[:msg].gsub(/\/(.+):/, '')}"
    paso_datos2 << "Mensaje Privado para #{user[1]} : #{params[:msg].gsub(/\/(.+):/, '')}"
    settings.connections.keys.each{|key| paso_datos1 << key}
    settings.connections.keys.each{|key| paso_datos2 << key}
    settings.connections[user[1]] << "data: #{paso_datos1}\n\n"
    settings.connections[params[:user]] << "data: #{paso_datos2}\n\n"
    204 # response without entity body
  end
end