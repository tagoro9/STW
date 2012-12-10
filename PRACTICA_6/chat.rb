# coding: utf-8
require 'sinatra'
set server: 'thin', users: {}

get '/' do
  halt erb(:login) unless params[:user]
  erb :chat, locals: { user: params[:user].gsub(/\W/, '') }
end

get '/stream/:user', provides: 'text/event-stream' do
  stream :keep_open do |out|
    settings.users[params[:user]] = out
    out.callback { settings.users.delete out }
    out.errback do
      logger.warn 'we just lost the connection!'
      settings.users.delete(out)
    end
  end
end

post '/' do
  nick_regexp = /\/(.+):.*/
  nickname = nick_regexp.match(params[:msg])
  receiver = settings.users[nickname[1]] unless nickname.nil?
  if nickname.nil?
    msg = "<b>#{params[:user]}</b>: #{params[:msg]}"
    settings.users.each_pair { |user, out| out << "data: #{msg}\n\n" }
  elsif receiver.nil?
    settings.users[params[:user]] << "data: <u>No user with such nickname!</u>\n\n"
  else
    msg = params[:msg].clone
    msg.slice! "/#{nickname[1]}:"
    msg1 = "<b>PM from #{params[:user]}</b>:<i>#{msg}</i>"
    msg2 = "<b>PM to #{nickname[1]}</b>:<i>#{msg}</i>"
    receiver << "data: #{msg1}\n\n"
    settings.users[params[:user]] << "data: #{msg2}\n\n"
  end
  204 # response without entity body
end

__END__

@@layout
<html>
  <head> 
    <title>Super Simple Chat with Sinatra</title> 
    <meta charset="utf-8" />
    <link href="//netdna.bootstrapcdn.com/twitter-bootstrap/2.2.2/css/bootstrap-combined.min.css" rel="stylesheet">
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script> 
  </head> 
  <body style="margin: 10px"><%= yield %></body>
</html>

@@login
<form class="form-inline" action='/'>
  <fieldset>
    <legend>Log in</legend>
    <label for='user'>User Name:</label>
    <input type='input-small' name='user' value='' />
    <input type='submit' value="GO!" class="btn"/>
  </fieldset>
</form>

@@chat
<h4>Hello <%= user %>! </h4>
<pre id='chat'></pre>

<script>
  // reading
  var url = "/stream/" + "<%= user %>"
  var es = new EventSource(url);
  es.onmessage = function(e) { $('#chat').append(e.data + "\n") };

  // writing
  $("form").live("submit", function(e) {
    $.post('/', {user: "<%= user %>", msg: $('#msg').val()});
    $('#msg').val(''); $('#msg').focus();
    e.preventDefault();
  });
</script>

<form>
  <input id='msg' placeholder='type message here...' />
</form>
