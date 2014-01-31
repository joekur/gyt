require "spec_helper"

describe Gyt::Commit do
  def new_commit(meta={})
    Gyt::Commit.new(test_repo, "message", Gyt::Tree.new(test_repo), meta)
  end

  describe Gyt::Commit::Role do
    describe "self.parse" do
      it "parses name, email and time" do
        role = Gyt::Commit::Role.new("John Smith", "johnsmith@gythub.com", Time.now.utc)
        parsed_role = Gyt::Commit::Role.parse(role.to_s)

        parsed_role.name.should == role.name
        parsed_role.email.should == role.email
        parsed_role.timestamp.to_i.should == role.timestamp.to_i
      end
    end
  end

  describe "self.read" do
    it "parses the commit object" do
      tree = Gyt::Tree.new(test_repo)
      tree.write
      t = Time.now
      commit_obj = [
        "commit\0",
        "tree #{tree.id}\n",
        "author John Smith <john@gmail.com> #{t.to_i} -0600\n",
        "committer Jane Smith <jane@gmail.com> #{t.to_i} -0600"
      ].join

      id = Gyt::Store.new(test_repo).write(commit_obj)
      commit = Gyt::Commit.read(test_repo, id)

      commit.message.should
      commit.tree.should == tree
      commit.author.name.should == "John Smith"
      commit.author.email.should == "john@gmail.com"
      commit.authored_at.to_i.should == t.to_i
      commit.committer.name.should == "Jane Smith"
      commit.committer.email.should == "jane@gmail.com"
      commit.committed_at.to_i.should == t.to_i
    end
  end

  describe "self.new" do
    it "initializes author and committer" do
      # TODO - implement gyt config
      commit = new_commit
      commit.author.name.should == "John Smith"
      commit.author.email.should == "johnsmith@gythub.com"
      commit.author.timestamp.to_i.should == Time.now.to_i
      commit.committer.name.should == "John Smith"
      commit.committer.email.should == "johnsmith@gythub.com"
      commit.committer.timestamp.to_i.should == Time.now.to_i
    end
  end

  describe "header" do
    it "is the commit type" do
      commit = Gyt::Commit.new(test_repo, "message", Gyt::Tree.new(test_repo))
      commit.header.should == "commit"
    end
  end

  describe "content" do
    it "formats data for tree and message" do
      commit = Gyt::Commit.new(test_repo, "message", Gyt::Tree.new(test_repo))
      commit.content.should == "tree #{commit.tree.id}\n\nmessage"
    end

    it "includes any meta data" do
      commit = Gyt::Commit.new(test_repo, "message", Gyt::Tree.new(test_repo), {
        author: "John Smith",
        parent: "1234"
      })
      commit.content.should include("author John Smith")
      commit.content.should include("parent 1234")
    end
  end

  describe "parent" do
    it "is nil with no parent_id" do
      commit = Gyt::Commit.new(test_repo, "message", Gyt::Tree.new(test_repo))
      commit.parent.should be_nil
    end

    it "points to the parent commit" do
      parent = Gyt::Commit.new(test_repo, "first commit", Gyt::Tree.new(test_repo))
      parent.write
      commit = Gyt::Commit.new(test_repo, "message", Gyt::Tree.new(test_repo), {
        parent: parent.id
      })

      commit.parent.should == parent
    end
  end
end
