# frozen_string_literal: true

require './main'
require 'sidekiq/web'

Sidekiq::Web.use Rack::Session::Cookie, secret: ENV.fetch('SIDEKIQ_SESSION_SECRET'), same_site: true, max_age: 86_400

run Rack::URLMap.new(
  '/' => Main,
  '/sidekiq' => Sidekiq::Web
)
