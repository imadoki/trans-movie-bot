# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'

class TransMovie
  def self.download(url:, &block)
    new.download(url: url, &block)
  end

  def self.trans_mp4(url:, &block)
    new.download(url: url) do |target|
      system("ffmpeg -y -i #{target.path} -acodec copy -map 0:0 result.mp4")
      raise 'not found result.mp4' unless File.exist?('result.mp4')

      File.open('result.mp4', &block)
      system('rm -rf result.mp4')
    end
  end

  def download(url:)
    response = conn.get(url)
    ::Tempfile.create(binmode: true) do |f|
      f.write(response.body)
      # NOTE: 書き込んだ内容を読めるようにrewindする
      f.rewind
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
