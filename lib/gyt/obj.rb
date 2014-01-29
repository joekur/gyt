require 'digest/sha1'

module Gyt
  class Obj
    def self.read(repo, id)
      object_file = Gyt::Store.new(repo).read(id)
      return if object_file.nil?

      header = object_file.split("\0").first
      type = header.split(" ").first

      case type
      when Gyt::Blob::TYPE
        Gyt::Blob.read(repo, id)
      when Gyt::Tree::TYPE
        Gyt::Tree.read(repo, id)
      when Gyt::Commit::TYPE
        Gyt::Commit.read(repo, id)
      end
    end

    def to_store
      "#{header}\0#{content}"
    end

    def write
      store.write(self.to_store)
    end

    def store
      @store ||= Gyt::Store.new(@repo)
    end

    def id
      Digest::SHA1.hexdigest(to_store)
    end

    def ==(t)
      self.content == t.content
    end
  end
end
