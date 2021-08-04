require 'sinatra'
require 'json'

configure do
  set :bind, '0.0.0.0'
  set :port, ENV.fetch('PORT')
end

get '/' do
  'hello world'
end

post '/receive' do
  request.body.rewind
  data = JSON.parse(request.body.read)
  case data['type']
  when 'url_verification'
    data
  else
    raise NotImplementedError
  end
end