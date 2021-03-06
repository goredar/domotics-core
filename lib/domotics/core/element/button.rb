module Domotics::Core
  class Button < Element
    def initialize(args = {})
      @type = args[:type] || :button
      @touch = args[:touch]
      @taped = true
      #@tap_lock = Mutex.new
      args[:driver] = @touch ? "DigitalSensor" : "NOSensor"
      load_driver args
      super
    end
    def set_state(*args)
      nil
    end

    def state_changed(value)
      case value
      when :on
        (@last_on = Time.now; @taped = false) if @taped
      when :off
        case Time.now - (@last_on || Time.now)
        when 0...0.01 then return # debounce
        when 0.01...0.3 then super :tap; @taped = true
        when 0.3...1 then super :long_tap; @taped = true
          #@tap_lock.synchronize do
          #  if @tap and @tap.alive?
          #    @tap.kill
          #    @tap = nil
          #    super :double_tap
          #  else
          #    @tap = Thread.new { sleep 0.25; super :tap }
          #  end
          #end
        else super :long_tap_x2; @taped = true
        end
      end
    end
  end
end
