# frozen_string_literal: true

require 'sidekiq'

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL') }
end

Dir["#{File.dirname(__FILE__)}/workers/*.rb"].each { |f| require f }
