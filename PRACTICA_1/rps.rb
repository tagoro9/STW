require 'sinatra'
require 'erb'

before do
  content_type :html
  @defeat = { rock: :scissors, paper: :rock, scissors: :paper}
  @throws = @defeat.keys
end

get '/' do
   erb :index
end

post '/' do
   redirect "/throw/#{params[:player_move]}"
end

get '/throw/:type' do
  # the params hash stores querystring and form data
  @player_throw = params[:type].to_sym

  halt(403, "You must throw one of the following: '#{@throws.join(', ')}'") unless @throws.include? @player_throw

  @computer_throw = @throws.sample

  if @player_throw == @computer_throw 
    @answer = "There is a tie"
    erb :result
  elsif @player_throw == @defeat[@computer_throw]
    @answer = "Computer wins; #{@computer_throw} defeats #{@player_throw}"
    erb :result
  else
    @answer = "Well done. #{@player_throw} beats #{@computer_throw}"
    erb :result
  end
end
