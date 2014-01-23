module Gyt
  class Blob
    def self.save(repo, content)
      body = self.header(content) + content
      Gyt::Store.new(repo).write(body)
    end

    def self.header(content)
      "blob #{content.bytesize}\0"
    end

    attr_reader :bytesize, :content
    def initialize(repo, key)
      object_body = Gyt::Store.new(repo).read(key)
      header, @content = object_body.split("\0", 2)
      @bytesize = header.split(" ")[1].to_i
    end
  end
end
