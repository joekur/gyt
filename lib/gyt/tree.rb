module Gyt
  class Tree < Obj
    TYPE = "tree"

    def self.read(repo, id)
      object_file = Gyt::Store.new(repo).read(id)
      header, contents = object_file.split("\0", 2)
      type = header
      raise "Not a tree object" if type != Gyt::Tree::TYPE

      children = contents.split("\n").map do |child_info|
        child_type, id, name = child_info.split(" ", 3)
        if child_type == Gyt::Tree::TYPE
          Gyt::Tree.read(repo, id)
        else
          Gyt::Blob.read(repo, id)
        end.tap {|c| c.name = name}
      end

      self.new(repo, children)
    end

    def self.build_from_dir(repo, directory)
      children = []
      directory.entries.each do |entry|
        entry_name = File.basename(entry.path)
        child = if entry.directory?
                Gyt::Tree.build_from_dir(repo, entry).tap {|t| t.name = entry_name}
              else
                Gyt::Blob.new(repo, entry.content, entry_name)
              end
        children << child
      end

      self.new(repo, children, directory.name)
    end

    attr_reader :children
    attr_accessor :name
    def initialize(repo, children=[], name=nil)
      @repo = repo
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
        "#{child.type} #{child.id} #{child.name}"
      end.join("\n")
    end

    def write
      children.each {|c| c.write}
      super
    end

    def type
      TYPE
    end
  end
end
