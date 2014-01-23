module Gyt
  class Directory
    attr_reader :path

    def initialize(path)
      @path = File.expand_path(path)
    end

    def files
      entries.select {|f| !File.directory?(f) }
    end

    def directories
      entries.select {|f| File.directory?(f) }
    end

    def entries
      entry_names = Dir.entries(path) - ['.', '..', '.gyt']
      entry_names.map do |entry_name|
        full_path = File.join(path, entry_name)
        if File.directory?(full_path)
          Gyt::Directory.new(full_path)
        else
          Gyt::Entry.new(full_path)
        end
      end
    end

    def directory?
      true
    end
  end
end
