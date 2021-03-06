ENV['RACK_ENV'] = 'test'

require "test/unit"
require "domotics/core"

class DomoticsRoomsTestCase < Test::Unit::TestCase
  def test_room
    tr = Domotics::Core::Room.new name: :tr
    assert_raise NoMethodError do
      tr.instance_eval { no_method :arg1 }
    end
    assert_nothing_raised do
      tr.instance_eval { nothing.off }
      tr.instance_eval { nothing.light :off }
    end
  end
end
