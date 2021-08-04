require 'sinatra'

configure do
  set :bind, '0.0.0.0'
  set :port, ENV.fetch('PORT')
end

get '/' do
  'hello world'
end