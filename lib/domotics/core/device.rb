module Domotics::Core
  class Device
    @@devices = {}
    attr_reader :name, :type
    def initialize(args = {})
      @name = args[:name] || SecureRandom.hex
      @@devices[@name] = self
      @type = args[:type] || "undefined"
    end

    def self.[](symbol = nil)
      return @@devices[symbol] if symbol
      @@devices
    end

    def destroy
      @@devices[@name] = nil
    end
    def to_s
      "Room[#{@name}](id:#{__id__})"
    end
  end
end
