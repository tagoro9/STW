require 'sinatra'

before do
  content_type :html
  @defeat = {:rock => :paper, :paper => :scissors, :scissors => :rock}
  @throws = @defeat.keys
end

get '/' do
  erb :index
end

post '/' do
  player_throw = params[:radio].to_sym
puts player_throw.inspect
  halt 403, "You must throw one of the following: #{@throws}" unless @throws.include? player_throw
  computer_throw = @throws.sample

  if player_throw == computer_throw
    @answer = "You tied with the computer. Try again."
  elsif computer_throw == @defeat[player_throw]
    @answer = "You win."
  else
    @answer = "Computer wins."
  end
end

get '/' do
  erb :result
end
