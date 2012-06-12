require 'sinatra'
require 'syntaxi'

class String
  def formatted_body leng
    source = "[code lang= '#{leng}']
                #{self}
              [/code]"
    html = Syntaxi.new(source).process
    %Q{
      <div class="syntax #{leng}">
        #{html}
      </div>
    }
  end
end

get '/' do
  erb :new
end

post '/' do
  @Salida = params[:body].formatted_body params[:Lenguaje]
  erb :mostrar
end