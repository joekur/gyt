require 'digest/sha1'

module Gyt
  class Obj
    def to_store
      "#{header}\0#{content}"
    end

    def write(repo)
      Gyt::Store.new(repo).write(self.to_store)
    end

    def sha1
      Digest::SHA1.hexdigest(to_store)
    end
  end
end
