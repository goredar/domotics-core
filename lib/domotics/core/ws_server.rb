module Domotics::Core
  class WsServer
    def initialize(args = {})
      @args = args
      @channel = EM::Channel.new
    end
    def run
      EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|
        ws.onopen do
          sid = @channel.subscribe { |msg| ws.send msg }
          ws.onmessage do |msg|
            
          end
          ws.onclose do
            @channel.unsubscribe(sid)
          end
        end
      end
    end
  end
end