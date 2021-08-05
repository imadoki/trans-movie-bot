# frozen_string_literal: true

class SlackClient
  def self.post_message(channel:, text:)
    new.post('/api/chat.postMessage', params(channel: channel, text: text))
  end

  def self.params(channel:, text:)
    {
      token: ENV.fetch('SLACK_BOT_USER_TOKEN'),
      channel: channel,
      text: text
    }
  end

  def post(...)
    conn.post(...)
  end

  def conn
    Faraday::Connection.new(url: 'https://slack.com') do |builder|
      builder.request :json
      builder.request :url_encoded
      builder.request :authorization, :Bearer, ENV.fetch('SLACK_BOT_USER_TOKEN')
      builder.response :logger
      builder.adapter Faraday.default_adapter
    end
  end
end