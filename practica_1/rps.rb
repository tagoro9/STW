require 'sinatra'
require 'erb'

before do
  content_type :html
  @defeat = { rock: :scissors, paper: :rock, scissors: :paper}
  @throws = @defeat.keys
end

get '/' do
   @title = "Choose one of the following"
   erb :index
end

post '/' do
   redirect "/throw/#{params[:player_move]}"
end

get '/throw/?:type?' do
  # the params hash stores querystring and form data
  @player_throw = (params[:type] || "").downcase.to_sym

  halt(403, "You must throw one of the following: '#{@throws.join(', ')}'") unless @throws.include? @player_throw

  @computer_throw = @throws.sample

  if @player_throw == @computer_throw 
    @class = "warning"
    @answer = "There is a tie"
    erb :result
  elsif @player_throw == @defeat[@computer_throw]
    @class = "error"
    @answer = "Computer wins"
    erb :result
  else
    @class = "success"
    @answer = "Well done. You win!"
    erb :result
  end
end
