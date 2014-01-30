module Gyt
  class Repository
    attr_reader :dir, :gyt_path

    def self.init(directory_path)
      gyt_path = File.join(directory_path, ".gyt")
      if File.directory?(gyt_path)
        puts "Reinitializing existing Gyt repository in #{directory_path}"
      else
        puts "Initializing new Gyt repository in #{directory_path}"
        Dir.mkdir(gyt_path)
      end
      repo = self.new(directory_path)
      repo.setup_gyt_folder
      repo
    end

    def self.repository?(directory_path)
      File.directory? File.join(directory_path, ".gyt")
    end

    def initialize(directory_path)
      @dir = Directory.new repository_path_for(directory_path)
      @gyt_path = File.join(directory_path, ".gyt")
    end

    def path
      dir.path
    end

    def ls_objects
      objects_dir.directories.map(&:files).flatten.map(&:path)
    end

    def setup_gyt_folder
      init_folder('objects')
      init_file('index')
      init_file('HEAD')
      init_folder('refs')
      init_folder('refs/heads')
      init_folder('refs/tags')
      create_branch("master")
    end

    def add(filepath)
      filepath = File.join(path, filepath)
      entry = Gyt::Entry.build(filepath)
      obj = if entry.directory?
              Gyt::Tree.build_from_dir(self, entry)
            else
              Gyt::Blob.new(self, entry.content, entry.name)
            end
      index.add(obj)
    end

    def commit!(msg, options={})
      if staged.empty?
        puts "Nothing to commit"
        return
      end
      commit_tree = Gyt::Tree.new(self, staged)
      options[:parent] = head unless head.nil?
      commit = Gyt::Commit.new(self, msg, commit_tree, options)
      commit.write
      refs.get("refs/heads/master").set(commit.id)
      index.clean

      commit
    end

    def head
      head_file = File.read(File.join(@gyt_path, "HEAD"))
      if head_file.include?("ref: ")
        ref_path = head_file.split(" ")[1]
        refs.get(ref_path).id
      else
        head_file
      end
    end

    def head_commit
      head.nil? ? nil : Gyt::Commit.read(self, head)
    end

    def create_branch(branch)
      ref_path = "refs/heads/#{branch}"
      refs.create(ref_path)
      File.write(File.join(@gyt_path, "HEAD"), "ref: #{ref_path}")
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

    def refs
      @refs ||= Gyt::Refs.new(self)
    end

    def log
      commit = head_commit
      while !commit.nil?
        puts "commit #{commit.id}".yellow
        puts "Author: #{commit.author}"
        puts ""
        puts "    " + commit.message
        puts ""

        commit = commit.parent
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

    def repository_path_for(path)
      while path != "/"
        return path if Gyt::Repository.repository?(path)
        path = File.dirname(path)
      end
      raise "Fatal - not a gyt repository"
    end
  end
end
