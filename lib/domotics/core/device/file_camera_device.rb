module Domotics::Core
  class FileCameraDevice < Device #__as__ :file_camera

    attr_accessor :mode
    attr_reader :current_file_name, :camera_element

    def initialize(args = {})
      @sensors = []
      @current_file_name = nil
      @mode = args[:mode] || :watch
      # Emulate element
      args[:device] = self
      @camera_element = Domotics::FileCamera::CameraElement.new args
      # Path to shots
      @path = args[:path] || "/tmp"
      @path.chop! if @path[-1] == "/"
      # Shots file extension
      @file_ext = args[:file_ext] || ".jpg"
      @file_ext = ".#{@file_ext}" unless @file_ext[0] == "."
      # Remove old shots
      FileUtils.rm Dir.glob("#{@path}/*#{@file_ext}")
      # Watch for new shots
      Thread.new do
        INotify::Notifier.new.tap do |x|
          x.watch(@path, :create) { |event| event_handler event }
        end.run
      end
      super
    end

    def register_sensor(sensor)
      @sensors << sensor
    end

    def event_handler(event)
      return if File.extname(event.name) != @file_ext
      # Wait untill close file and rename it
      sleep 0.25
      case @mode
      when :save
        dir_name = Time.now.strftime("%Y%m%d")
        FileUtils.mkdir_p "#{@path}/#{dir_name}"
        @current_file_name = "#{@path}/#{dir_name}/#{Time.now.to_i}#{@file_ext}"
        File.rename "#{@path}/#{event.name}", @current_file_name
      when :watch
        @current_file_name = "#{@path}/current#{@file_ext}"
        File.rename "#{@path}/#{event.name}", @current_file_name
      else #:delete
        @current_file_name = nil
        FileUtils.rm "#{@path}/#{event.name}"
      end
      @sensors.each { |sensor| sensor.state_changed :motion_detection }
    end

    def current_link
      "#{@camera_element.room.name}/#{@camera_element.name}/file/#{Time.now.to_i}#{@file_ext}"
    end

    def current_file
      IO.read @current_file_name if @current_file_name
    end
  end
end