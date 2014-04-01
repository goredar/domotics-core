module Domotics
  module FileCamera
    class CameraElement < Domotics::Core::Element
      def image
        @device.current_link
      end
      def file(*args)
        @device.current_file
      end
      def mode(param)
        @device.mode = param
        set_state param
      end
    end
  end
end