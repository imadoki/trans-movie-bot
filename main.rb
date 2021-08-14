# frozen_string_literal: true

require 'sinatra/base'
require 'json'
require 'sidekiq'
require './lib/event_callback'

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL') }
end

class Main < Sinatra::Base
  get '/' do
    'hello world'
  end

  post '/receive' do
    request.body.rewind
    data = JSON.parse(request.body.read)
    case data['type']
    when 'url_verification'
      data.to_json
    when 'event_callback'
      EventCallback.run(uata)
    else
      raise NotImplementedError
    end
  end
end
