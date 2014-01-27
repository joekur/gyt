module Gyt
  class Refs
    def initialize(repo)
      @repo = repo
    end

    def get(ref_path)
      ref_path = File.join(@repo.gyt_path, ref_path)
      return nil unless File.exist?(ref_path)
      Gyt::Ref.new(ref_path)
    end

    def create(ref_path, id=nil)
      ref_path = File.join(@repo.gyt_path, ref_path)
      File.write(ref_path, id)
      Gyt::Ref.new(ref_path)
    end
  end

  class Ref
    def initialize(file_path)
      @file_path = file_path
    end

    def id
      ref_file = File.read(@file_path)
      if ref_file.length > 0
        ref_file
      else
        nil
      end
    end

    def set(new_id)
      File.write(@file_path, new_id)
    end
  end
end
