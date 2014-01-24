module Gyt
  class Directory < Entry
    attr_reader :path

    def initialize(path)
      @path = File.expand_path(path)
    end

    def files
      entries.select {|e| !e.directory? }
    end

    def directories
      entries.select {|e| e.directory? }
    end

    def entries
      entry_names = Dir.entries(path) - ['.', '..', '.gyt']
      entry_names.map do |entry_name|
        full_path = File.join(path, entry_name)
        Gyt::Entry.build(full_path)
      end
    end

    def directory?
      true
    end
  end
end
