# frozen_string_literal: true

require 'sidekiq'
require './lib/slack_client'
require './lib/trans_movie'

class TransMp4Worker
  include Sidekiq::Worker

  def perform(channel, url)
    SlackClient.post_message(channel: channel, text: 'start translation')
    TransMovie.trans_mp4(url: url) do |f|
      SlackClient.upload_file(channels: [channel], file: f)
    end
  end
end
