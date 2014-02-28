ENV['RACK_ENV'] = 'test'

require "test/unit"
require "domotics/core"

Domotics::Core::TestHelper.init

class DomoticsDevicesTestCase < Test::Unit::TestCase
end
