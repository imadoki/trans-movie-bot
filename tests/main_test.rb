# frozen_string_literal: true

require './main'
require 'minitest/autorun'
require 'rack/test'
require 'rr'
require './lib/event_callback'

# rubocop:disable Metrics/AbcSize, Minitest/MultipleAssertions
class MainTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Main
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
    stub(SlackClient).auth_test { { 'ok' => true, 'user_id' => 'bot_user_id' } }
    result = event_callback(data)
    assert_nil result
    assert_received(SlackClient) { |klass| klass.post_message(channel: anything, text: anything).once }
    assert_received(SlackClient) { |klass| klass.auth_test.once }
  end

  def test_event_callback_when_dm_self
    data = json_data('./tests/data/dm_event_self.json')
    stub(SlackClient).post_message
    stub(SlackClient).auth_test { { 'ok' => true, 'user_id' => 'bot_user_id' } }
    result = event_callback(data)
    assert_nil result
    assert_received(SlackClient) { |klass| klass.post_message(channel: anything, text: anything).never }
    assert_received(SlackClient) { |klass| klass.auth_test.once }
  end

  def test_event_callback_when_dm_attached_file
    data = json_data('./tests/data/dm_event_attached_file.json')
    stub(SlackClient).auth_test { { 'ok' => true, 'user_id' => 'bot_user_id' } }
    stub(TransMp4Worker).perform_async
    stub(SlackClient).post_message
    result = event_callback(data)
    assert_nil result
    assert_received(SlackClient) { |klass| klass.auth_test.once }
    assert_received(TransMp4Worker) { |klass| klass.perform_async(is_a(String), is_a(String)).once }
    assert_received(SlackClient) { |klass| klass.post_message(channel: is_a(String), text: is_a(String)).once }
  end

  def test_event_callback_when_dm_attached_file_self
    data = json_data('./tests/data/dm_event_attached_file_self.json')
    stub(SlackClient).auth_test { { 'ok' => true, 'user_id' => 'bot_user_id' } }
    stub(TransMp4Worker).perform_async
    stub(SlackClient).post_message
    result = event_callback(data)
    assert_nil result
    assert_received(SlackClient) { |klass| klass.auth_test.once }
    assert_received(TransMp4Worker) { |klass| klass.perform_async(is_a(String), is_a(String)).never }
    assert_received(SlackClient) { |klass| klass.post_message(channel: is_a(String), text: is_a(String)).never }
  end

  def json_data(file_path)
    File.open(file_path) do |f|
      JSON.parse(f.read)
    end
  end

  def event_callback(data)
    EventCallback.run(data)
  end
end
# rubocop:enable Metrics/AbcSize, Minitest/MultipleAssertions
