module Domotics::Core
  class WsServer
    @@parent = nil
    def initialize(args = {})
      @logger = Domotics::Core::Setup.logger || Logger.new(STDERR)
      @args = args
      @@parent, @child = Socket.pair(:UNIX, :DGRAM, 0)
    end
    def run
      @logger.info { "[WebSocket] server [#{@args[:host]}:#{@args[:port]}]" }
      fork do
        @@parent.close
        channel = EventMachine::Channel.new
        Thread.new { loop { channel.push @child.recv(2**10) }}
        EventMachine::WebSocket.start(@args) do |ws|
          ws.onopen do
            sid = channel.subscribe { |msg| ws.send msg }
            @logger.info { "[WebSocket] client [#{sid}]" }
            ws.onmessage do |msg|
              @logger.info { "[WebSocket] message [#{msg}] from [#{sid}]" }
            end
            ws.onclose do
              channel.unsubscribe(sid)
            end
          end
        end
      end
      @child.close
    end
    def self.publish(msg)
      @@parent.send msg, 0 if @@parent
    end
  end
end