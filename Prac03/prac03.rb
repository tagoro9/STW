require 'sinatra'
require 'syntaxi'

class String
  def formatted_body lang
    source = "[code lang='#{lang}']
                #{self}
              [/code]"
    html = Syntaxi.new(source).process
    %Q{
      <div class="#{lang}">
        #{html}
      </div>
    }
  end
end

get '/' do
  erb :new
end

post '/' do
  @Codigo = params[:body].formatted_body params[:opc]
  erb :ver
end
