#ENV['RACK_ENV'] = 'test'

require "domotics/core"
require 'test/unit'
require 'rack/test'

class DomoticsTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Domotics::Core::Server.new
  end

  def test_valid_object
    get '/to_s'
    assert last_response.bad_request?
    get '/test/to_s'
    assert last_response.ok?
    get '/test/light_1/to_s'
    assert last_response.ok?
    get '/invalid_object/to_s'
    assert last_response.bad_request?
    get '/test/invalid_object/to_s'
    assert last_response.bad_request?
  end

  def test_query_action
    get '/test/light_1/state'
    assert last_response.ok?
    get '/test/light_1/abracadabra'
    assert last_response.bad_request?
    get '/test/light_1/state/abracadabra'
    assert last_response.bad_request?
  end

  def test_switch_element
    get '/test/light_1/on'
    assert last_response.ok?
    get '/test/light_1/delay_off/1'
    assert last_response.ok?
    sleep 1.2
    get '/test/light_1/delay_on/1'
    assert last_response.ok?
    sleep 1.2
    3.times do
      sleep 1
      get '/test/light_1/toggle'
      assert last_response.ok?
    end
    get '/test/light_1/delay_toggle/1'
    assert last_response.ok?
    sleep 2
    get '/test/light_1/off'
    assert last_response.ok?
  end

end
