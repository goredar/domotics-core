module Domotics
  module FileCamera
    module DigitalSensor
      def initialize(args = {})
        @device ||= args[:device]
        @device && @device.register_sensor(self)
        super
      end
    end
  end
end