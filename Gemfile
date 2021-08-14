# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'faraday'
gem 'faraday_middleware'
gem 'puma'
gem 'sidekiq'
gem 'sinatra'

group :development, :test do
  gem 'minitest'
  gem 'rack-test'
  gem 'rr', require: false
  gem 'rubocop', require: false
  gem 'rubocop-minitest', require: false
  gem 'rubocop-performance', require: false
end
