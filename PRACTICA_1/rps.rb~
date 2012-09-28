require 'sinatra'
require 'erb'

before do
  content_type :html
  @defeat = {:rock => :paper, :paper => :scissors, :scissors => :rock}
  @throws = @defeat.keys
end

get '/' do
  erb :index
end

post '/' do
  redirect "http://localhost:4567/throw/#{params[:radio]}"
end

get '/throw/:type' do
  @player_throw = params[:type].to_sym
  halt 403, "You must throw one of the following: #{@throws}" unless @throws.include? @player_throw
  @computer_throw = @throws.sample

  @answer = if @player_throw == @computer_throw
    "You tied with the computer. Try again."
  elsif @computer_throw == @defeat[@player_throw]
    "You win."
  else
    "Computer wins."
  end
  erb :result
end
