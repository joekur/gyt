module Gyt
  class Index
    attr_accessor :objects

    def initialize(repo)
      @repo = repo
      load_objects
    end

    def load_objects
      @objects = File.read(path).split("\n").map do |object_info|
        type, sha1, name = object_info.split(" ", 3)
        if type == Gyt::Tree::TYPE
          Gyt::Tree.read(@repo, sha1)
        else
          Gyt::Blob.read(@repo, sha1)
        end.tap {|c| c.name = name}
      end
    end

    def add(obj)
      objects << obj
      objects.sort
      obj.write(@repo)
      write
    end

    def write
      File.write(path, to_store)
    end

    def to_store
      objects.map do |obj|
        "#{obj.type} #{obj.sha1} #{obj.name}"
      end.join("\n")
    end

    def path
      File.join(@repo.gyt_path, "index")
    end
  end
end
