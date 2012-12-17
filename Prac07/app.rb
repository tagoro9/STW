require 'sinatra'
set server: 'thin', conecciones: Hash.new

get '/' do
  halt erb(:login) unless params[:user]
  erb :chat, locals: { user: params[:user]}#.gsub(/\W/, '') }
end

get '/stream/:user', provides: 'text/event-stream' do
  stream :keep_open do |out|
    settings.conecciones[params[:user]] = out
	mensaje = "#{params[:user]} se ha unido"
	datos = []
	datos << mensaje
    settings.conecciones.keys.each {|k| datos << k}
    settings.conecciones.each_pair { |user, out| out << "data: #{datos}\n" }
	204
	out.callback {
       usu = settings.conecciones.key out
       settings.conecciones.delete usu
       data = []
       data << "#{usu} se ha ido"
       settings.conecciones.keys.each {|k| data << k}
       settings.conecciones.each_pair { |user, out| out << "data: #{data}\n\n" }
       204 # response without entity body
    }
  end
end

post '/' do
  NickName_ER = /\/(.+):.*/
  usuario = NickName_ER.match(params[:msg])
  if usuario.nil?
	mensaje = "<div class=\"mensajeUsuario\"><span class=\"nick\">#{params[:user]}:</span> <span id=\"mensaje\">#{params[:msg]}</span></div>\n"
	
    #mensaje = "#{params[:user]}: #{params[:msg]}"
	datos = []
	datos << mensaje
    settings.conecciones.keys.each {|k| datos << k}
    settings.conecciones.each_pair { |user, out| out << "data: #{datos}\n\n" }
  else
  
    settings.conecciones[usuario[1]] << "data: <span class=\"private\"> #{params[:usuario]} :</span> <span class=\"private_msj\">#{params[:msg].gsub(/\/(.+):/, '')}</span>\n\n"
    settings.conecciones[params[:usuario]] << "data: <span class=\"private\">-> #{usuario[1]} :</span> <span class=\"private_msj\"> #{params[:msg].gsub(/\/(.+):/, '')}</span>\n\n"
  
    mensaje1 = "data: <span class=\"private\"> #{params[:usuario]} :</span> <span class=\"private_msj\">#{params[:msg].gsub(/\/(.+):/, '')}</span>\n\n"
    mensaje2 = "data: <span class=\"private\">-> #{usuario[1]} :</span> <span class=\"private_msj\"> #{params[:msg].gsub(/\/(.+):/, '')}</span>\n\n"
    datos1 =[]
    datos2 = []
    datos1 << mensaje1
    datos2 << mensaje2
    settings.conecciones.keys.each {|k| 
      datos1 << k
      datos2 << k
    }
    #usuario << "data: #{datos1}\n\n"
    settings.conecciones[user[1]] << "data: #{datos1}\n\n"
    settings.conecciones[params[:user]] << "data: #{datos2}\n\n" 
  end
  204
end