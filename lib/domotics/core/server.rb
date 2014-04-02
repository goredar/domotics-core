module Domotics::Core
  class Server
    def initialize(args = {})
      @logger = Domotics::Core::Setup.logger || Logger.new(STDERR)
    end
    def call(env)
      # [object]/[action]/[params]
      request = env['PATH_INFO'][1..-1].split('/')
      request[-1], form = request.last.split(".")
      object = request.shift
      return invalid 'room' unless object and object = Room[object.to_sym]
      return invalid 'element or action' unless object_action = request.shift
      if sub_object = object[object_action.to_isym]
        room, object = object, sub_object
        action = request.shift
      else
        room = object
        action = object_action
      end
      return invalid 'action' unless action and object.respond_to? action
      begin
        result = object.public_send(action, *request.map { |param| param.to_isym })
      rescue Exception => e
        @logger.error { e.message }
        @logger.debug { e }
        return invalid 'request'
      end
      case form
      when "json"
        return ok object.verbose_state.to_json
      when "jpg"
        return jpg result if result
        return invalid 'request'
      else
        return ok object.verbose_state.to_s
      end
    end

    private

    def invalid(param)
      [400, {"Content-Type" => "text/html"}, ["Processing error: invalid #{param}."]]
    end
    def ok(param)
      [200, {"Content-Type" => "text/html"}, [param]]
    end
    def jpg(param)
      [200, {"Content-Type" => "image/jpeg"}, [param]]
    end
  end
end
