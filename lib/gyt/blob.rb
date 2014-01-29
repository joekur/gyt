module Gyt
  class Blob < Obj
    TYPE = "blob"

    def self.read(repo, id)
      object_file = Gyt::Store.new(repo).read(id)
      header, content = object_file.split("\0", 2)
      type, bytesize = header.split(" ", 2)
      raise "Not a blob object" if type != Gyt::Blob::TYPE

      self.new(repo, content)
    end

    attr_reader :content
    attr_accessor :name
    def initialize(repo, content, name=nil)
      @repo = repo
      @content = content
      @name = name
    end

    def header
      "#{type} #{content.bytesize}"
    end

    def type
      TYPE
    end
  end
end
