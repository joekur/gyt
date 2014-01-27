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
              Gyt::Tree.build_from_dir(entry)
            else
              Gyt::Blob.new(entry.content, entry.name)
            end
      index.add(obj)
    end

    def commit!(msg, options={})
      if staged.empty?
        puts "Nothing to commit"
        return
      end
      commit_tree = Gyt::Tree.new(staged)
      options[:parent] = head unless head.nil?
      commit = Gyt::Commit.new(msg, commit_tree, options)
      commit.write(self)
      refs.get("refs/heads/master").set(commit.sha1)
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
      id = head
      while !id.nil?
        commit = Gyt::Commit.read(self, id)
        puts "commit #{id}"
        puts "author: #{commit.author}"
        puts ""
        puts commit.message
        puts ""

        id = commit.parent_id
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
