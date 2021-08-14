# frozen_string_literal: true

require 'sidekiq'
require './lib/slack_client'

class TestWorker
  include Sidekiq::Worker

  def perform(channel)
    SlackClient.post_message(channel: channel, text: 'test_worker')
  end
end
