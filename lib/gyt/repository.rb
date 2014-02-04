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
      @gyt_path = File.join(@dir.path, ".gyt")
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

      if head.id.nil?
        commit_tree = Gyt::Tree.new(self, staged)
      else
        options[:parent] = head.id
        commit_tree = head.commit.tree.merge(staged)
      end

      commit = Gyt::Commit.new(self, msg, commit_tree, options)
      commit.write

      head.ref.set(commit.id)
      head.id = commit.id

      index.clean

      commit
    end

    def create_branch(branch)
      ref_path = "refs/heads/#{branch}"
      refs.create(ref_path, head.id)
      checkout(branch)
    end

    def checkout(target, options={})
      ref_path = "refs/heads/#{target}"

      if target == branch
        puts "Already on '#{target}'"
        return
      end

      if options[:branch]
        # create new branch
        refs.create(ref_path, head.id)
      end

      ref = refs.get(ref_path)
      if ref
        # target is a branch
        head.write("ref: #{ref_path}")
        puts "Switched to branch '#{target}'"
      else
        obj = Gyt::Obj.read(self, target)
        if obj && obj.type == Gyt::Commit::TYPE
          # target is a commit id
          head.write(obj.id)
        else
          # target doesn't exist
          raise "pathspec '#{target}' did not match any file(s) known to gyt"
        end
      end
    end

    def branch
      head.branch
    end

    def staged
      index.objects
    end

    def status
      puts "# On branch #{branch}"
      puts "Changes to be committed:"
      index.objects.each do |obj|
        puts obj.name
      end
    end

    def refs
      @refs ||= Gyt::Refs.new(self)
    end

    def head
      @head ||= Gyt::Head.new(self)
    end

    def log
      commit = head.commit
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
