# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'

class SlackClient
  def self.post_message(channel:, text:)
    new.post_message('/api/chat.postMessage', params(channel: channel, text: text))
  end

  def self.params(channel:, text:)
    {
      token: ENV.fetch('SLACK_BOT_USER_TOKEN'),
      channel: channel,
      text: text
    }
  end

  def self.upload_file(channels:, file:)
    new.upload_file(channels: channels, file: file)
  end

  def self.auth_test
    new.auth_test
  end

  def post_message(...)
    connection_use_json.post(...)
  end

  def upload_file(channels:, file:)
    payload = {
      channels: channels.join(','),
      inline_comment: 'アップロードしました',
      file: Faraday::FilePart.new(file, 'video/mp4', 'reupload.mp4')
    }
    connection_use_multipart.post('/api/files.upload', payload)
  end

  def auth_test
    connection_use_json.post('/api/auth.test').body
  end

  def connection_use_json
    Faraday::Connection.new(url: 'https://slack.com') do |builder|
      builder.adapter Faraday.default_adapter
      builder.request :json
      builder.request :authorization, :Bearer, ENV.fetch('SLACK_BOT_USER_TOKEN')
      builder.response :logger
      builder.response :json, content_type: /\bjson$/
    end
  end

  def connection_use_multipart
    Faraday::Connection.new(url: 'https://slack.com') do |builder|
      builder.adapter Faraday.default_adapter
      builder.request :multipart
      builder.request :authorization, :Bearer, ENV.fetch('SLACK_BOT_USER_TOKEN')
      builder.response :logger
    end
  end
end
