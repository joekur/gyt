module Gyt
  class Head
    attr_accessor :id
    attr_reader :branch

    def initialize(repo)
      @repo = repo
      read!
    end

    def detached?
      @branch.nil?
    end

    def commit
      if id.nil?
        nil
      else
        Gyt::Commit.read(@repo, id)
      end
    end

    def write(str)
      File.write(file_path, str)
      read!
    end

  private

    def read!
      head_file = File.read(file_path)
      if head_file.include?("ref: ")
        ref_path = head_file.split(" ")[1]
        @ref = refs.get(ref_path)
        @id = @ref.id
        @branch = File.basename(ref_path)
      else
        @ref = nil
        @id = head_file.length > 0 ? head_file : nil
        @branch = nil
      end
    end

    def file_path
      File.join(@repo.gyt_path, "HEAD")
    end

    def refs
      @refs ||= Gyt::Refs.new(@repo)
    end
  end
end
