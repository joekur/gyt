require 'digest/sha1'

module Gyt
  class Obj
    def self.read(repo, sha1)
      object_file = Gyt::Store.new(repo).read(sha1)
      return if object_file.nil?

      header = object_file.split("\0").first
      type = header.split(" ").first

      case type
      when Gyt::Blob::TYPE
        Gyt::Blob.read(repo, sha1)
      when Gyt::Tree::TYPE
        Gyt::Tree.read(repo, sha1)
      when Gyt::Commit::TYPE
        Gyt::Commit.read(repo, sha1)
      end
    end

    def to_store
      "#{header}\0#{content}"
    end

    def write(repo)
      Gyt::Store.new(repo).write(self.to_store)
    end

    def sha1
      Digest::SHA1.hexdigest(to_store)
    end

    def ==(t)
      self.content == t.content
    end
  end
end
