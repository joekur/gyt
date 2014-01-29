module Gyt
  class Commit < Obj
    TYPE = "commit"

    def self.read(repo, id)
      object_file = Gyt::Store.new(repo).read(id)
      header, rest = object_file.split("\0", 2)
      meta, msg = rest.split("\n\n", 2)
      type = header
      raise "Not a commit object" if type != Gyt::Commit::TYPE

      meta_hash = {}
      meta.each_line do |meta_info|
        key, value = meta_info.split(" ", 2)
        meta_hash[key.to_sym] = value
      end

      tree = Gyt::Tree.read(repo, meta_hash.delete(:tree))

      self.new(repo, msg, tree, meta_hash)
    end

    attr_accessor :tree, :message

    def initialize(repo, message, tree, meta={})
      @repo = repo
      @message = message
      @tree = tree
      @meta = meta
    end

    def header
      type
    end

    def content
      meta = {tree: @tree.id}.merge(@meta).map do |key, value|
        "#{key} #{value}"
      end.join("\n")
      "#{meta}\n\n#{@message}"
    end

    def write
      @tree.write
      super
    end

    def parent_id
      @meta[:parent]
    end

    def author
      @meta[:author]
    end

    def type
      TYPE
    end
  end
end
