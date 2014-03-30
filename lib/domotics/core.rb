require 'bundler/setup'
# From data_mongo
require 'mongo'
# From data_redis
require 'redis'
require 'hiredis'
# From arduino_board
#require "../domotics-arduino/lib/domotics/arduino"
require 'domotics/arduino'
# From server
require 'json'
# From file_camera_device
require 'rb-inotify'

module Domotics
  module Core
    # Map config names to real classes
    CLASS_MAP = {}
    # Scan file for class name and add to CLASS_MAP
    def self.add_map(args = {})
      realm = args[:realm] || self
      if args[:file]
        class_name = nil
        index = nil
        require args[:file]
        IO.read(args[:file]).each_line do |line|
          if line =~ /class\s*([A-Z]\w*)[\s\w<]*(#__as__ :(\w*))?/
            class_name, index = $1, $3 && $3.to_sym
            break
          end
        end
        return unless class_name
      end
      class_name ||= args[:class_name]
      index ||= class_name.split(/(?=[A-Z])/).map{ |cnp| cnp.downcase }.join('_').to_sym
      klass = realm.const_get(class_name)
      CLASS_MAP[index] = [args[:type], klass]
    end
  end
end

gem_path = File.dirname(__FILE__)
#require all
%w(core/data/*.rb core/*.rb core/helper/*.rb file_camera/*.rb).each do |path|
  Dir["#{gem_path}/#{path}"].each {|file| require file}
end
# scan all devices and elements and populate class map
[:device, :room, :element].each do |type|
  Dir["#{gem_path}/core/#{type}/*.rb"].each do |file|
    Domotics::Core.add_map type: type, file: file
  end
end
