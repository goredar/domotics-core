ENV['RACK_ENV'] = 'test'

require "test/unit"
require "domotics/core"

Domotics::Core::TestHelper.init

class DomoticsDevicesTestCase < Test::Unit::TestCase
  def test_file_camera
    # General
    cam = Domotics::Core::Device[:cam]
    assert_equal "cam", cam.name.to_s
    assert_equal "test/cam/file/#{Time.now.to_i}.jpg", cam.current_link
    # Watch mode (default)
    %x{echo "[test foto content]" > /tmp/test_foto_1.jpg}
    sleep 0.5
    assert_equal "/tmp/current.jpg", cam.current_file_name
    assert_equal "[test foto content]", cam.current_file.chomp
    # Save mode
    cam.mode = :save
    dir_name = Time.now.strftime("%Y%m%d")
    %x{rm -rf /tmp/#{dir_name}}
    %x{echo "[test foto content]" > /tmp/test_foto_2.jpg}
    name = Time.now.to_i
    sleep 0.5
    assert_match /\/tmp\/#{dir_name}\/#{name/100}\d{2}.jpg/, cam.current_file_name
    assert_equal "[test foto content]", cam.current_file.chomp
    # Delete mode
    cam.mode = :delete
    %x{echo "[test foto content]" > /tmp/test_foto_3.jpg}
    sleep 0.5
    assert_nil cam.current_file_name
    assert_nil cam.current_file
    # Test CameraElement
    assert_equal "test/cam/file/#{Time.now.to_i}.jpg", cam.camera_element.image
    cam.camera_element.mode :watch
    assert_equal :watch, cam.camera_element.state
    %x{echo "[test foto content]" > /tmp/test_foto_4.jpg}
    sleep 0.5
    assert_equal "[test foto content]", cam.camera_element.file.chomp
    assert_equal Domotics::Core::Room[:test].last_event(cam.camera_element.name), :state_changed => :new_image
  end
end