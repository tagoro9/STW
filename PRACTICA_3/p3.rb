require 'sinatra'
require 'syntaxi'

class String
  def formatted_body lang
    source = "[code lang='#{lang}']
                #{self}
              [/code]"
    html = Syntaxi.new(source).process
    %Q{
      <div class="syntax #{lang}">
        #{html}
      </div>
    }
  end
end

get '/' do
  erb :new
end

post '/' do
  @output = params[:body].formatted_body params[:language]
  erb :show
end
