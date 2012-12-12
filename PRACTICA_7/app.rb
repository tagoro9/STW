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
    data = []
    data << "#{params[:user]} has joined the chat"
    settings.users.keys.each {|k| data << k}
    settings.users.each_pair { |user, out| out << "data: #{data}\n\n" }
    204 # response without entity body

    out.callback {
       name = settings.users.key out
       settings.users.delete name
       data = []
       data << "#{name} has left the chat"
       settings.users.keys.each {|k| data << k}
       settings.users.each_pair { |user, out| out << "data: #{data}\n\n" }
       204 # response without entity body
    }
  end
end

post '/' do
  has_nick_expr = /\/(.+):.*/
  nick = has_nick_expr.match(params[:msg])
  connection = settings.users[nick[1]] unless nick.nil?
  if connection.nil?
    msg = "#{params[:user]}: #{params[:msg]}"
    data = []
    data << msg
    settings.users.keys.each {|k| data << k}
    settings.users.each_pair { |user, out| out << "data: #{data}\n\n" }
    204 # response without entity body
  else
    msg = params[:msg].clone
    msg.slice! ("/#{nick[1]}:")
    msg1 = "PM form #{params[:user]} #{msg}"
    msg2 = "PM to #{nick[1]} #{msg}"
    data1 =[]
    data2 = []
    data1 << msg1
    data2 << msg2
    settings.users.keys.each {|k| 
      data1 << k
      data2 << k
    }
    connection << "data: #{data1}\n\n"
    settings.users[params[:user]] << "data: #{data2}\n\n" 
    204 # response without entity body
  end  
end
