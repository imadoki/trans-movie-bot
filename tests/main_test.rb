require './main'
require 'minitest/autorun'
require 'rack/test'

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
    params = {type: 'url_verification'}.to_json
    post '/receive', params
    assert last_response.ok?
    assert_equal params, last_response.body
  end
end