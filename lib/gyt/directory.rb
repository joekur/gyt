module Gyt
  class Directory
    attr_reader :path

    def initialize(path)
      @path = File.expand_path(path)
    end

    def files
      Dir.entries(path).select {|f| !File.directory?(f) }
    end

    def directories
      Dir.entries(path).select {|f| File.directory?(f) }
    end
  end
end
