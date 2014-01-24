module Gyt
  class Tree < Obj
    TYPE = "tree"

    def self.read(repo, sha1)
      object_file = Gyt::Store.new(repo).read(sha1)
      header, contents = object_file.split("\0", 2)
      type = header
      raise "Not a tree object" if type != Gyt::Tree::TYPE

      children = contents.split("\n").map do |child_info|
        child_type, sha1, name = child_info.split(" ", 3)
        if child_type == Gyt::Tree::TYPE
          Gyt::Tree.read(repo, sha1)
        else
          Gyt::Blob.read(repo, sha1)
        end.tap {|c| c.name = name}
      end

      self.new(children)
    end

    def self.build_from_dir(directory)
      children = []
      directory.entries.each do |entry|
        entry_name = File.basename(entry.path)
        child = if entry.directory?
                Gyt::Tree.build_from_dir(entry).tap {|t| t.name = entry_name}
              else
                Gyt::Blob.new(entry.content, entry_name)
              end
        children << child
      end

      self.new(children, directory.name)
    end

    attr_reader :children
    attr_accessor :name
    def initialize(children=[], name=nil)
      @children = children
      @name = name
    end

    def add_child(child)
      children << child
    end

    def header
      TYPE
    end

    def content
      children.map do |child|
        "#{child.type} #{child.sha1} #{child.name}"
      end.join("\n")
    end

    def write(repo)
      children.each {|c| c.write(repo)}
      super
    end

    def type
      TYPE
    end
  end
end
