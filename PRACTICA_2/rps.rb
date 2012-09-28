require 'sinatra'
require 'haml'

configure do
  enable :sessions
end

before do
  content_type :html
  @defeat = {:rock => :paper, :paper => :scissors, :scissors => :rock}
  @throws = @defeat.keys
  session[:you] = "0" if session[:you].nil?
  session[:computer] = "0" if session[:computer].nil?
end

get '/' do
  haml :index
end

post '/' do
  redirect "http://localhost:4567/throw/#{params[:radio]}"
end

get '/throw/:type' do
  player_throw = params[:type].to_sym
  halt 403, "You must throw one of the following: #{@throws}" unless @throws.include? player_throw
  computer_throw = @throws.sample

  answer = if player_throw == computer_throw
    "You tied with the computer. Try again."
  elsif player_throw == @defeat[computer_throw]
    session[:you] = (session[:you].to_i + 1).to_s
    "You win."
  else
    session[:computer] = (session[:computer].to_i + 1).to_s
    "Computer wins."
  end
  haml :result, :locals => {:player_throw => player_throw, :computer_throw => computer_throw, :answer => answer}
end
