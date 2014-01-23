require 'zlib'
require 'digest/sha1'

module Gyt
  class Store
    def initialize(repo)
      @repo = repo
    end

    def write(data)
      sha1 = Digest::SHA1.hexdigest(data)
      zipped_content = Zlib::Deflate.deflate(data)
      file_path = path_for(sha1)

      Dir.mkdir(File.dirname(file_path))
      File.write(file_path, zipped_content)

      sha1
    end

    def read(sha1)
      zipped_content = File.read(path_for(sha1))
      Zlib::Inflate.inflate(zipped_content)
    end

    def path_for(sha1)
      File.join(@repo.gyt_path, "objects", sha1[0,2], sha1[2,38])
    end
  end
end
