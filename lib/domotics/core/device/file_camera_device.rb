module Domotics::Core
  class FileCameraDevice < Device #__as__ :file_camera
    def initialize(args = {})
      # Emulate element
      @current_link = "xxx"
      @camera_element = Element.new args
      s = self
      image_lambda = lambda { s.current_link }
      file_lambda = lambda { |*args| s.current_file }
      @camera_element.eigenclass.send :define_method, :image, image_lambda
      @camera_element.eigenclass.send :define_method, :file, file_lambda
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
    def event_handler(event)
      filename = "#{@path}/#{event.name}"
      # Wait untill close file and rename it
      inot = INotify::Notifier.new
      inot.watch(filename, :close_write) do |file|
        @current_name = "#{@path}/#{Time.now.to_i}#{@file_ext}"
        sleep 0.1
        File.rename filename, @current_name
      end
      inot.process
      inot.close
    end
    def current_link
      "#{@camera_element.room.name}/#{@camera_element.name}/file/#{Time.now.to_i}#{@file_ext}"
    end
    def current_file(*args)
      IO.read @current_name
    end
  end
end