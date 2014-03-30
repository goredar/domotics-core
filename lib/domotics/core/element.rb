module Domotics::Core
  class Element
    @@data = DataHash.new
    attr_reader :name, :type, :room

    def initialize(args = {})
      @room = args[:room]
      @room.register_element self, @name = args[:name]
      @type ||= :element
      set_state(self.state || :off)
    end

    def load_driver(args = {})
      return unless args[:device_type]
      device_space = args[:device_type].to_s.split("_").map{ |x| x.capitalize }.join
      self.class.class_eval(%(include Domotics::#{device_space}::#{args[:driver]}), __FILE__, __LINE__)
    end

    def state
      @@data[self].state
    end

    def verbose_state
      { @room.name =>
        { :elements =>
          { @name =>
            { :state => state,
              :info => info,
              :img => image,
            }
          }
        }
      }
    end

    def info
      nil
    end

    def image
      nil
    end

    def set_state(value)
      @@data[self].state = value
      @room.notify({ event: :state_set, element: self }) unless @type == :dimmer
    end

    def state_changed(value)
      @@data[self].state = value
      @room.notify event: :state_changed, element: self
    end

    def self.data=(value)
      @@data = value
    end

    def to_s
      "Element[#{@room.name}@#{@name}](id:#{__id__})"
    end
  end
end
