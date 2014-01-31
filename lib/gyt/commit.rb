module Gyt
  class Commit < Obj
    TYPE = "commit"

    class Role
      attr_accessor :name, :email, :timestamp

      def self.parse(str)
        matchdata = /(.*) <(.*)> (.*) (.*)/.match(str)
        name, email, time_s, zone = matchdata.captures
        self.new(name, email, Time.at(time_s.to_i))
      end

      def initialize(name, email, timestamp=Time.now)
        @name = name
        @email = email
        @timestamp = timestamp
      end

      def to_s
        "#{name} <#{email}> #{timestamp.to_i} #{timestamp.strftime('%z')}"
      end
    end

    def self.read(repo, id)
      object_file = Gyt::Store.new(repo).read(id)
      header, rest = object_file.split("\0", 2)
      meta, msg = rest.split("\n\n", 2)
      type = header
      raise "Not a commit object" if type != Gyt::Commit::TYPE

      meta_hash = {}
      meta.each_line do |meta_info|
        key, value = meta_info.split(" ", 2)
        meta_hash[key.to_sym] = value
      end

      tree = Gyt::Tree.read(repo, meta_hash.delete(:tree))
      meta_hash[:author] = Gyt::Commit::Role.parse(meta_hash[:author]) if meta_hash[:author]
      meta_hash[:committer] = Gyt::Commit::Role.parse(meta_hash[:committer]) if meta_hash[:committer]

      self.new(repo, msg, tree, meta_hash)
    end

    attr_accessor :tree, :message, :author, :committer

    def initialize(repo, message, tree, meta={})
      @repo = repo
      @message = message
      @tree = tree
      @meta = meta

      @author = meta[:author] || Gyt::Commit::Role.new("John Smith", "johnsmith@gythub.com")
      @committer = meta[:committer] || Gyt::Commit::Role.new("John Smith", "johnsmith@gythub.com")
    end

    def header
      type
    end

    def content
      meta = {tree: @tree.id}.merge(@meta).map do |key, value|
        "#{key} #{value}"
      end.join("\n")
      "#{meta}\n\n#{@message}"
    end

    def write
      @tree.write
      super
    end

    def parent_id
      @meta[:parent]
    end

    def parent
      parent_id.nil? ? nil : Gyt::Commit.read(@repo, parent_id)
    end

    def authored_at
      author.timestamp
    end

    def committed_at
      committer.timestamp
    end

    def type
      TYPE
    end
  end
end
