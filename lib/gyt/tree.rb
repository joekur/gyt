module Gyt
  class Tree
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
        child = if entry.directory?
                Gyt::Tree.new(entry)
              else
                Gyt::Blob.new(entry.content)
              end
        children << child
      end

      self.new(children)
    end

    attr_reader :children
    def initialize(children)
      @children = children
    end

    def header
      "#{TYPE}\0"
    end

    def to_s
      # not implemented
    end

    def write(repo)
      # not implemented
    end
  end
end
