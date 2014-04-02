module Domotics::Core
  class WsServer
    @@channel = EM::Channel.new
    def initialize(args = {})
      @logger = Domotics::Core::Setup.logger || Logger.new(STDERR)
      @args = args
    end
    def run
      Thread.new do
        @logger.info { "Starting WebSocet Server on #{@args[:host]}:#{@args[:port]}" }
        EventMachine::WebSocket.start(@args) do |ws|
          ws.onopen do
            sid = @@channel.subscribe { |msg| ws.send msg }
            ws.onmessage do |msg|
              @logger.info { "WebSocket message [#{msg}] from client [#{sid}]" }
            end
            ws.onclose do
              @@channel.unsubscribe(sid)
            end
          end
        end
      end
    end
    def self.publish(msg)
      @@channel.push msg
    end
  end
end