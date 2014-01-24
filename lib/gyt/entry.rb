module Gyt
  class Entry
    def self.build(path)
      path = File.expand_path(path)
      if File.directory?(path)
        Gyt::Directory.new(path)
      else
        Gyt::Document.new(path)
      end
    end

    def name
      File.basename(path)
    end
  end
end
