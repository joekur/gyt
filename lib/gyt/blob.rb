module Gyt
  class Blob < Obj
    TYPE = "blob"

    def self.write(repo, content)
      body = self.header(content) + content
      Gyt::Store.new(repo).write(body)
    end

    def self.read(repo, sha1)
      object_file = Gyt::Store.new(repo).read(sha1)
      header, content = object_file.split("\0", 2)
      type, bytesize = header.split(" ", 2)
      raise "Not a blob object" if type != Gyt::Blob::TYPE

      self.new(content)
    end

    attr_reader :content
    attr_accessor :name
    def initialize(content, name=nil)
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
