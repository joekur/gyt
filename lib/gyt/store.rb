module Gyt
  class Store
    require 'zlib'
    require 'digest/sha1'

    def initialize(repo)
      @repo = repo
    end

    def write(data)
      key = Digest::SHA1.hexdigest(data)
      zipped_content = Zlib::Deflate.deflate(data)
      file_path = path_for(key)

      Dir.mkdir(File.dirname(file_path))
      File.write(file_path, zipped_content)

      key
    end

    def read(key)
      zipped_content = File.read(path_for(key))
      Zlib::Inflate.inflate(zipped_content)
    end

    def path_for(key)
      File.join(@repo.gyt_path, "objects", key[0,2], key[2,38])
    end
  end
end
