module Gyt
  class Repository
    attr_reader :dir, :gyt_path

    def self.init(directory_path)
      repo = self.new(directory_path)
      repo.setup_gyt_folder
      repo
    end

    def initialize(directory_path)
      @dir = Directory.new(directory_path)
      @gyt_path = File.join(directory_path, ".gyt")
    end

    def path
      dir.path
    end

    def ls_objects
      objects_dir.directories.map(&:files).flatten.map(&:path)
    end

    def setup_gyt_folder
      if File.directory?(@gyt_path)
        puts "Reinitializing existing Gyt repository in #{@gyt_path}"
      else
        puts "Initializing new Gyt repository in #{@gyt_path}"
      end
      init_folder('/')
      init_folder('objects')
      init_file('index')
    end

    def add(filepath)
      filepath = File.join(path, filepath)
      entry = Gyt::Entry.build(filepath)
      obj = if entry.directory?
              Gyt::Tree.build_from_dir(entry)
            else
              Gyt::Blob.new(entry.content, entry.name)
            end
      index.add(obj)
    end

    def commit!(msg, options={})
      if staged.empty?
        puts "Nothing to commit"
        return false
      end
      commit_tree = Gyt::Tree.new(staged)
      commit = Gyt::Commit.new(msg, commit_tree, options)
      sha1 = commit.write(self)
      index.clean

      sha1
    end

    def staged
      index.objects
    end

    def status
      puts "Changes to be committed:"
      index.objects.each do |obj|
        puts obj.name
      end
    end

  private

    def objects_dir
      @objects_dir ||= Gyt::Directory.new File.join(@gyt_path, "objects")
    end

    def init_folder(path)
      full_path = File.join(@gyt_path, path)
      Dir.mkdir(full_path) unless File.directory?(full_path)
    end

    def init_file(path)
      full_path = File.join(@gyt_path, path)
      File.write(full_path, "") unless File.file?(full_path)
    end

    def index
      @index ||= Gyt::Index.new(self)
    end
  end
end
