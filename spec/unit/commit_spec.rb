require "spec_helper"

describe Gyt::Commit do
  describe "self.read" do
    it "parses the commit object" do
      tree = Gyt::Tree.new(test_repo)
      tree.write
      commit_obj = [
        "commit\0",
        "tree #{tree.id}\n",
        "author John Smith <john@gmail.com>"
      ].join

      id = Gyt::Store.new(test_repo).write(commit_obj)
      commit = Gyt::Commit.read(test_repo, id)

      commit.message.should
      commit.tree.should == tree
      commit.author.should == "John Smith <john@gmail.com>"
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
        author: "John Smith",
        parent: parent.id
      })

      commit.parent.should == parent
    end
  end
end
