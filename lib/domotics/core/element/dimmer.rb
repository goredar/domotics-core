module Domotics::Core
  class Dimmer < Element

    DEFAULT_LEVEL = 0
    MIN_LEVEL = 0
    MAX_LEVEL = 255
    MAX_STEPS = 128
    STEP_DELAY = 1.0 / MAX_STEPS
    STEP_SIZE = ((MAX_LEVEL + 1) / MAX_STEPS.to_f).round

    def initialize(args = {})
      @type = args[:type] || :dimmer
      @fade_lock = Mutex.new
      @fade_thread = nil
      args[:driver] = "PWMPin"
      load_driver args
      super
    end

    def state
      st = super
      st.is_a?(Integer) ? st : 0
    end
    def set_state(value = DEFAULT_LEVEL, opt = {})
      unless opt[:kill_fader] == :no
        @fade_lock.synchronize do
          @fade_thread.kill if @fade_thread and @fade_thread.alive?
        end
      end
      if value.is_a? Integer
        value = MIN_LEVEL if value < MIN_LEVEL
        value = MAX_LEVEL if value > MAX_LEVEL
      end
      super value
    end
    # Decrease brightness level (value 0-100%)
    def dim(value = nil)
      if value
        set_state value * MAX_LEVEL / 100
      else
        set_state state - STEP_SIZE
      end
    end
    # Increase brightness level (value 0-100%)
    def bright(value = nil)
      if value
        set_state value * MAX_LEVEL / 100
      else
        set_state state + STEP_SIZE
      end
    end

    def off
      set_state MIN_LEVEL unless state == MIN_LEVEL
    end

    def fade_to(value = DEFAULT_LEVEL, speed_divisor = 1)
      @fade_lock.synchronize do
        @fade_thread.kill if @fade_thread and @fade_thread.alive?
        @fade_thread = Thread.new do
          op = (value - state) >= 0 ? :+ : :-
          steps = ((value - state).abs / STEP_SIZE.to_f).round
          steps.times do
            set_state(state.public_send(op, STEP_SIZE), kill_fader: :no)
            sleep speed_divisor * STEP_DELAY
          end
          @fade_lock.synchronize { @fade_thread = nil }
        end
      end
      @fade_thread
    end
  end
end
