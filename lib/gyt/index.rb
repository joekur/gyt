module Gyt
  class Index
    def initialize(repo)
      @repo = repo
    end

    def path
      File.join(@repo.path, "index")
    end
  end
end
