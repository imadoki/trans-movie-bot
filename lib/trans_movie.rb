# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'

class TransMovie
  def self.download(url:, &block)
    new.download(url: url, &block)
  end

  def download(url:)
    response = conn.get(url)
    Tempfile.create(binmode: true) do |f|
      f.write(response.body)
      yield f
    end
  end

  def conn
    Faraday::Connection.new do |builder|
      builder.adapter Faraday.default_adapter
      builder.request :authorization, :Bearer, ENV.fetch('SLACK_BOT_USER_TOKEN')
      builder.response :logger
    end
  end
end
