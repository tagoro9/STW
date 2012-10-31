require 'sinatra'
require 'syntaxi'
require 'erb'

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

before do
	content_type :html
end

get '/' do
  erb :new
end

post '/' do
	@output = params[:codigo].formatted_body params[:language]
	erb :result
end
