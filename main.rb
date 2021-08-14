# frozen_string_literal: true

require 'sinatra'
require 'json'
require './lib/slack_client'
require './lib/trans_movie'

# FIXME: fix rubocop warning
# rubocop:disable Metrics/AbcSize, Metrics/MethodLength
def event_callback(data)
  puts data

  res = SlackClient.auth_test
  raise 'bot infomation is not found.' unless res['ok']

  bot_user_id = res['user_id']

  raise NotImplementedError if data['event']['type'] != 'message' || data['event']['channel_type'] != 'im'

  return if data.dig('event', 'user') == bot_user_id

  if data.dig('event', 'files') && data.dig('event', 'subtype') == 'file_share'
    TransMovie.download(url: data.dig('event', 'files', 0, 'url_private_download')) do |file|
      SlackClient.upload_file(channels: [data['event']['channel']], file: file)
    end
    nil
  else
    SlackClient.post_message(channel: data['event']['channel'],
                             text: 'はろー')
  end
end
# rubocop:enable Metrics/AbcSize, Metrics/MethodLength

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
