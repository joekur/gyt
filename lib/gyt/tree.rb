module Gyt
  class Tree < Obj
    TYPE = "tree"

    def self.read(repo, sha1)
      object_file = Gyt::Store.new(repo).read(sha1)
      header, contents = object_file.split("\0", 2)
      type = header
      raise "Not a tree object" if type != Gyt::Tree::TYPE
      contents.split("\n").each do |child_info|
        # not implemented
      end
    end

    def self.build_from_dir(directory)
      children = []
      directory.entries.each do |entry|
        entry_name = File.basename(entry.path)
        child = if entry.directory?
                Gyt::Tree.new(entry, entry_name)
              else
                Gyt::Blob.new(entry.content, entry_name)
              end
        children << child
      end

      self.new(children)
    end

    attr_reader :children, :name
    def initialize(children, name=nil)
      @children = children
      @name = name
    end

    def header
      TYPE
    end

    def content
      children.map do |child|
        "#{child.type} #{child.sha1} #{child.name}"
      end.join("\n")
    end

    def type
      TYPE
    end
  end
end
