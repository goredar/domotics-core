module Domotics::Core
  class ReedSwitch < Element
    def initialize(args = {})
      @type = args[:type] || :reed_switch
      args[:driver] = "NCSensor"
      load_driver args
      super
    end
    #def to_hls(state)
    #  super == :on ? :open : :close
    #end
    def set_state(*args)
      nil
    end
  end
end
