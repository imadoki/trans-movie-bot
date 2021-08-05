# frozen_string_literal: true

require 'sinatra'
require 'json'
require './lib/slack_client'

def event_callback(data)
  puts data

  raise NotImplementedError if data['event']['type'] != 'message' || data['event']['channel_type'] != 'im'

  SlackClient.post_message(channel: data['event']['channel'], text: 'はろー') if data['event']['subtype'] != 'bot_message'
end

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
    data.to_json
  when 'event_callback'
    event_callback(data)
  else
    raise NotImplementedError
  end
end
