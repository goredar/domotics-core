ENV['RACK_ENV'] = 'test'

require "test/unit"
require "domotics/core"

class DomoticsElementsTestCase < Test::Unit::TestCase
  def test_dimmer
    dimmer = Domotics::Core::Room[:test].dimmer
    # Should turn on max and convert state to int
    dimmer.set_state :on
    assert_equal 255, dimmer.state
    # Should turn off and convert state to int
    dimmer.set_state :off
    assert_equal 0, dimmer.state
    # Dim
    [0,3,24,127,237,255].each do |val|
      dimmer.set_state val
      assert_equal val, dimmer.state
    end
    # Off
    dimmer.off
    assert_equal 0, dimmer.state
    # Fade to
    dimmer.fade_to 255
    sleep 1.6
    assert_equal 255, dimmer.state
    dimmer.fade_to 127
    sleep 0.8
    assert_equal 127, dimmer.state
    dimmer.fade_to 0
    sleep 0.8
    assert_equal 0, dimmer.state
  end

  def test_rgb_strip
    rgb = Domotics::Core::Room[:test].rgb
    rgb.on
    sleep 1.6
    assert_equal 255, rgb.red.state
    rgb.off
    assert_equal 0, rgb.red.state
    assert_equal :dimmer, rgb.red.type
    assert_equal :dimmer, rgb.green.type
    assert_equal :dimmer, rgb.blue.type
  end

  def test_button
    room = Domotics::Core::Room[:test]
    btn = room.button

    $emul.set_internal_state 6, 1
    $emul.toggle_pin 6
    sleep 0.1
    $emul.toggle_pin 6
    sleep 0.05
    assert_equal room.last_event(btn.name), :state_changed => :tap
    $emul.toggle_pin 6
    sleep 0.6
    $emul.toggle_pin 6
    sleep 0.01
    assert_equal room.last_event(btn.name), :state_changed => :long_tap
  end

  def test_camera_motion_sensor
    room = Domotics::Core::Room[:test]
    cam_mt = room.cam_motion
    saved_mode = cam_el.device.mode
    %x{echo "[test foto content]" > /tmp/test_foto.jpg}
    sleep 0.5
    assert_equal room.last_event(cam_mt.name), :state_changed => :motion_detection
    assert_equal cam_el.device.mode, saved_mode
  end
end