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
      matching_dir = Gyt::Directory.new File.join(db_path, id[0,2])
      object_files = matching_dir.files
      matching_object = object_files.find do |file|
        file.name[0, id.length - 2] == id[2..-1]
      end

      if matching_object
        zipped_content = File.read(matching_object.path)
        Zlib::Inflate.inflate(zipped_content)
      else
        nil
      end
    rescue Errno::ENOENT
      nil
    end

    def clean(id)
      File.delete(path_for(id))
    end

  private

    def path_for(id)
      File.join(@repo.gyt_path, "objects", id[0,2], id[2,38])
    end

    def db_path
      File.join(@repo.gyt_path, "objects")
    end
  end
end
