# Debug - Show exception in threads
Thread.class_eval do
  alias_method :initialize_without_exception_show, :initialize
  def initialize(*args, &block)
    initialize_without_exception_show(*args) do
      begin
        block.call
      rescue Exception => e
        Domotics::Core::Setup.logger.error { e.message }
        Domotics::Core::Setup.logger.debug { e.inspect }
        nil
      end
    end
  end
end

class String
  # Return integer (if can convert) or symbol
  def to_isym
    begin
      Integer(self)
    rescue ArgumentError
      self.to_sym
    end
  end
end

module Domotics::Core
  # Suppress no method errors
  class BlackHole
    def method_missing(*args)
      self
    end
  end
end

module Domotics::Core
  class TestRoom < Room
    def initialize(args = {})
      super
      @events = {}
    end
    def event_handler(msg = {})
      event, element = msg[:event], msg[:element]
      if element
        @events[element.name] ||= []
        @events[element.name].push event => element.state
      end
      super
    end
    def last_event(element_name)
      @events[element_name].pop if @events[element_name].respond_to? :pop
    end
  end
end

module Domotics::Core
  class TestHelper
    def self.init
      $emul = Domotics::Arduino::BoardEmulator.new
      Domotics::Core.add_map type: :room, class_name: "TestRoom"
      Domotics::Core::Setup.new IO.read File.expand_path("../../../../test/config.test.rb", File.dirname(__FILE__))
    end
  end
end

class Object 
  def eigenclass
    class << self
      self
    end 
  end 
end
