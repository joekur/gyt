module Gyt
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
