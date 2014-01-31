require "gyt"

class GytCLI < Thor
  desc "init <pathspec>", "Initialize new Gyt repository"
  def init
    Gyt::Repository.init(current_dir)
  end

  desc "add <pathspec>", "Add file to index"
  def add(filepath)
    current_repo.add(filepath)
  end

  desc "status", "Show files to be committed"
  def status
    current_repo.status
  end

  desc "commit", "Commit staged files to history"
  method_option :message, aliases: "-m", desc: "Commit message", banner: "<commit>", required: true
  def commit
    current_repo.commit!(options[:message])
  end

  desc "log", "Show commit history"
  def log
    current_repo.log
  end

  desc "checkout", "Checkout branch, commit, tag"
  method_option :branch, aliases: "-b", desc: "Create new branch", banner: "<branch>", type: :boolean
  def checkout(target)
    current_repo.checkout(target, options)
  end

  no_commands do
    def current_dir
      File.expand_path('.')
    end

    def current_repo
      @repo ||= Gyt::Repository.new(current_dir)
    end
  end
end
