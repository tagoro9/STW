# coding: utf-8
require 'sinatra'
set server: 'thin', connections: [], users: Hash.new


get '/' do
  halt erb(:login) if params[:user].nil?
  erb :chat, locals: { user: params[:user] }
end

get '/stream2', provides: 'text/event-stream' do
  #if users.has_key?(params[:user])
   # puts "mierda estoy ocupado"
    #halt erb(:login)
  #else
    stream :keep_open do |out|
      settings.connections << out
      users[params[:user]] = out
      out.callback { settings.connections.delete(out) }
    end
  #end
end

get '/stream/:user', provides: 'text/event-stream' do
  stream :keep_open do |out|
    settings.connections << out
    settings.users[params[:user]] = out
    out.callback { settings.connections.delete(out) }
  end
end


post '/' do
  has_nick_expr = /\/(.+):.*/
  nick = has_nick_expr.match(params[:msg])
  connection = settings.users[nick[1]] unless nick.nil?
  if connection.nil?
    settings.connections.each { |out| out << "data: #{params[:msg]}\n\n" }
    204 # response without entity body
  else
    connection << "data: #{params[:msg]}\n\n"
    settings.users[params[:user]] << "data: #{params[:msg]}\n\n" 
  end  
end

__END__

@@ layout
<html>
  <head> 
    <title>Super Simple Chat with Sinatra</title> 
    <meta charset="utf-8" />
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script> 
  </head> 
  <body><%= yield %></body>
</html>

@@ login
<form action='/'>
  <label for='user'>User Name:</label>
  <input name='user' value='' />
  <input type='submit' value="GO IN THE CHAT!" />
</form>

@@ chat
<pre id='chat'></pre>

<script>
  // reading
  var url = "/stream/" + "<%= user %>"
  var es = new EventSource(url);
  es.onmessage = function(e) { $('#chat').append(e.data + "\n") };

  // writing
  $("form").live("submit", function(e) {
    $.post('/', {msg: "<%= user %>: " + $('#msg').val(), user: "<%= user %>" });
    $('#msg').val(''); $('#msg').focus();
    e.preventDefault();
  });
</script>

<form>
  <input id='msg' placeholder='type message here...' />
</form>
