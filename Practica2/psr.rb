require 'sinatra'
require 'haml'

configure do 
  enable:sessions
end

before do
  content_type:html
  @defeat = {:rock => :paper, :paper => :scissors, :scissors => :rock}
  @throws = @defeat.keys
  session[:You]= "0" if session[:You].nil?
  session[:Computer]="0" if session[:Computer].nil?
end

get '/' do
  haml:index
end


post '/' do
  @linea = params
   redirect "http://localhost:4567/throw/#{@linea[:opcion]}"
end

get '/throw/:type' do
  player_throw = params[:type].to_sym
  halt 403, "You must throw one of the following: #{@throws}" unless @throws.include? player_throw
  computer_throw = @throws.sample
  if player_throw == computer_throw
    answer = "You tied with the computer.Try again"
  elsif player_throw == @defeat[computer_throw]
    answer = "You win"
    session[:You]= (session[:You].to_i + 1).to_s
  else
    answer = "Computer wins"
    session[:Computer]=(session[:Computer].to_i + 1).to_s
  end
  haml:salida, :locals => { :answer => answer,
                   :player_throw => player_throw,
                   :computer_throw => computer_throw
  }
end

post '/reset' do
  session.clear
  redirect "/"
end