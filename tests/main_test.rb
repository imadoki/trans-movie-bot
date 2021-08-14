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

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def test_event_callback_when_dm_attached_file
    data = json_data('./tests/data/dm_event_attached_file.json')
    stub(SlackClient).upload_file
    any_instance_of(TransMovie) do |klass|
      stub(klass).conn do
        Faraday.new do |builder|
          builder.adapter :test, Faraday::Adapter::Test::Stubs.new do |s|
            s.get('https://files.example.com/files-pri/test/download/test.mp4') do |_env|
              [200, { 'Content-Type': 'video/mp4' }, File.open('./tests/data/test.mp4')]
            end
          end
        end
      end
    end
    result = event_callback(data)
    assert_nil result
    assert_received(SlackClient) { |klass| klass.upload_file(channels: is_a(Array), file: anything).once }
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def json_data(file_path)
    File.open(file_path) do |f|
      JSON.parse(f.read)
    end
  end
end
