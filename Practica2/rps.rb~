require 'sinatra'

before do
  content_type:txt
  @defeat = {:rock => :paper, :paper => :scissors, :scissors => :rock}
  @throws = @defeat.keys
end



get '/throw/:type' do
  player_throw = params[:type].to_sym
  halt 403, "You must throw one of the following: #{@throws}" unless @throws.include? player_throw
  computer_throw = @throws.sample
  if player_throw == computer_throw
    @answer = "you tied with the computer.Try again"
  elsif computer_throw == @defeat[player_throw]
    @answer = "you win"
  else
    @answer = "Computer win"
  end
  erb:salida
end


__END__
@@salida
<html>
  <body>
    <h1><%=@answer%></h1>
  </body>
</html>
