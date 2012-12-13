require 'sinatra'
set server: 'thin', conecciones: {}

get '/' do
  halt erb(:login) unless params[:usuario]
  erb :chat, locals: { user: params[:usuario].gsub(/\W/, '') }
end

get '/stream/:usuario', provides: 'text/event-stream' do
  stream :keep_open do |out|
    settings.conecciones[params[:usuario]] = out
    out.callback { settings.conecciones.delete(settings.conecciones.key out) }
  end
end

post '/' do
  NickName_ER = /\/(.+):.*/
  usuario = NickName_ER.match(params[:msg])
  if usuario.nil?
	mensaje = "<span class=\"nick\">#{params[:usuario]}:</span> <span class=\"mensaje\">#{params[:msg]}</span>\n"
    settings.conecciones.each_pair { |usuario, out| out << "data: #{mensaje}\n" }
  else
    settings.conecciones[usuario[1]] << "data: <span class=\"private\"> #{params[:usuario]} :</span> <span class=\"private_msj\">#{params[:msg].gsub(/\/(.+):/, '')}</span>\n\n"
    settings.conecciones[params[:usuario]] << "data: <span class=\"private\">-> #{usuario[1]} :</span> <span class=\"private_msj\"> #{params[:msg].gsub(/\/(.+):/, '')}</span>\n\n"
  end
  204
end