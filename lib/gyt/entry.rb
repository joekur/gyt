module Gyt
  class Entry
    attr_reader :path

    def initialize(path)
      @path = File.expand_path(path)
    end

    def directory?
      false
    end

    def content
      File.read(path)
    end
  end
end
