require 'zlib'
require 'digest/sha1'

module Gyt
  class Store
    def initialize(repo)
      @repo = repo
    end

    def write(data)
      id = Digest::SHA1.hexdigest(data)
      zipped_content = Zlib::Deflate.deflate(data)
      file_path = path_for(id)
      dir_path = File.dirname(file_path)

      Dir.mkdir(dir_path) unless File.directory?(dir_path)
      File.write(file_path, zipped_content)

      id
    end

    def read(id)
      zipped_content = File.read(path_for(id))
      Zlib::Inflate.inflate(zipped_content)
    rescue Errno::ENOENT
      nil
    end

    def clean(id)
      File.delete(path_for(id))
    end

    def path_for(id)
      File.join(@repo.gyt_path, "objects", id[0,2], id[2,38])
    end
  end
end
