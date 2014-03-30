module Domotics::Core
  class MotionSensor < Element
    def initialize(args = {})
      @type = args[:type] || :motion_sensor
      args[:driver] = "DigitalSensor"
      load_driver args
      super
    end
    #def to_hls(state)
    #  super == :on ? :move : :no_move
    #end
    def set_state(*args)
      nil
    end
  end
end
