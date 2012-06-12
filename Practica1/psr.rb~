require 'sinatra'

before do
  content_type:html
  @defeat = {:rock => :paper, :paper => :scissors, :scissors => :rock}
  @throws = @defeat.keys
end

get '/' do

  erb:index
  
end


post '/' do
  @linea = params[:post]
   redirect "http://localhost:4567/throw/#{@linea[:opcion]}"
end

get '/throw/:type' do
  player_throw = params[:type].to_sym
  halt 403, "You must throw one of the following: #{@throws}" unless @throws.include? player_throw
  computer_throw = @throws.sample
  if player_throw == computer_throw
    @answer = "You tied with the computer.Try again"
  elsif computer_throw == @defeat[player_throw]
    @answer = "You win"
  else
    @answer = "Computer win"
  end
  erb:salida
end










