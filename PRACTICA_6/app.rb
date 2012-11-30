# coding: utf-8
require 'sinatra'
set server: 'thin', connections: [], users: Hash.new

get '/' do
  halt erb(:login) if params[:user].nil?
  erb :chat, locals: { user: params[:user] }
end

#if users.has_key?(params[:user])

get '/stream/:user', provides: 'text/event-stream' do
  stream :keep_open do |out|
    settings.users[params[:user]] = out
    out.callback { settings.users.delete params[:user] }
  end
end

post '/' do
  has_nick_expr = /\/(.+):.*/
  nick = has_nick_expr.match(params[:msg])
  connection = settings.users[nick[1]] unless nick.nil?
  if connection.nil?
    msg = "#{params[:user]}: #{params[:msg]}"
    settings.users.each_pair { |user, out| out << "data: #{msg}\n\n" }
    204 # response without entity body
  else
    msg = params[:msg].clone
    msg.slice! ("/#{nick[1]}:")
    msg1 = "MP de #{params[:user]} #{msg}"
    msg2 = "MP para #{nick[1]} #{msg}"
    connection << "data: #{msg1}\n\n"
    settings.users[params[:user]] << "data: #{msg2}\n\n" 
    204 # response without entity body
  end  
end
