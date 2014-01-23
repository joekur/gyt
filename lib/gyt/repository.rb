module Gyt
  class Repository
    attr_reader :dir, :gyt_path

    def self.init(directory_path)
      repo = self.new(directory_path)
      repo.setup_gyt_folder
      repo
    end

    def initialize(directory_path)
      @dir = Directory.new(directory_path)
      @gyt_path = File.join(directory_path, ".gyt")
    end

    def path
      dir.path
    end

    def setup_gyt_folder
      Dir.mkdir(@gyt_path)
      Dir.mkdir(File.join(@gyt_path, "objects"))
    end
  end
end
