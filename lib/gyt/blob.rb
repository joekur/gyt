module Gyt
  class Blob
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
    def initialize(content)
      @content = content
    end

    def header
      "#{type} #{content.bytesize}\0"
    end

    def to_s
      header + content
    end

    def type
      TYPE
    end

    def write(repo)
      Gyt::Store.new(repo).write(self.to_s)
    end
  end
end
