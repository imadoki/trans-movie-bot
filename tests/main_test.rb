# frozen_string_literal: true

require './main'
require 'minitest/autorun'
require 'rack/test'
require 'rr'

class MainTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_root
    get '/'
    assert last_response.ok?
    assert_equal 'hello world', last_response.body
  end

  def test_receive
    params = { type: 'url_verification' }.to_json
    post '/receive', params
    assert last_response.ok?
    assert_equal params, last_response.body
  end

  def test_event_callback_when_dm_user
    data = json_data('./tests/data/dm_event.json')
    stub(SlackClient).post_message
    result = event_callback(data)
    assert_nil result
    assert_received(SlackClient) { |klass| klass.post_message(channel: anything, text: anything).once }
  end

  def test_event_callback_when_dm_self
    data = json_data('./tests/data/dm_event_self.json')
    stub(SlackClient).post_message
    result = event_callback(data)
    assert_nil result
    assert_received(SlackClient) { |klass| klass.post_message(channel: anything, text: anything).never }
  end

  def json_data(file_path)
    File.open(file_path) do |f|
      JSON.parse(f.read)
    end
  end
end
