# frozen_string_literal: true

require 'sinatra'
require 'json'
require './lib/slack_client'

# FIXME: fix rubocop warning
# rubocop:disable Metrics/AbcSize
def event_callback(data)
  puts data

  raise NotImplementedError if data['event']['type'] != 'message' || data['event']['channel_type'] != 'im'

  return if data.dig('event', 'bot_profile', 'app_id') == ENV.fetch('SLACK_BOT_APP_ID')

  if data.dig('event', 'files') && data.dig('event', 'subtype') == 'file_share'
    SlackClient.post_message(channel: data['event']['channel'],
                             text: data.dig('event', 'files', 0, 'title'))
  else
    SlackClient.post_message(channel: data['event']['channel'],
                             text: 'はろー')
  end
end
# rubocop:enable Metrics/AbcSize

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
