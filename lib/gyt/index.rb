module Gyt
  class Index
    attr_accessor :objects

    def initialize(repo)
      @repo = repo
      load_objects
    end

    def load_objects
      @objects = File.read(path).split("\n").map do |object_info|
        type, id, name = object_info.split(" ", 3)
        if type == Gyt::Tree::TYPE
          Gyt::Tree.read(@repo, id)
        else
          Gyt::Blob.read(@repo, id)
        end.tap {|c| c.name = name}
      end
    end

    def add(obj)
      objects << obj
      objects.sort! {|a,b| a.name <=> b.name}
      obj.write(@repo)
      write
    end

    def clean
      self.objects = []
      write
    end

    def write
      File.write(path, to_store)
    end

    def to_store
      objects.map do |obj|
        "#{obj.type} #{obj.id} #{obj.name}"
      end.join("\n")
    end

    def path
      File.join(@repo.gyt_path, "index")
    end
  end
end
