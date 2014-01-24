require "spec_helper"

describe Gyt::Tree do
  it "can read and write to object store" do
    blob = Gyt::Blob.new("text", "file.txt")
    subtree = Gyt::Tree.new([], "src")
    sha1 = Gyt::Tree.new([blob, subtree]).write(test_repo)

    tree = Gyt::Tree.read(test_repo, sha1)
    tree.children.first.name.should == "file.txt"
    tree.children.first.content.should == "text"
    tree.children.last.name.should == "src"
    tree.children.last.children.should be_empty
  end

  describe "self.write" do
    it "writes a file for itself and all children recursively" do
      blob = Gyt::Blob.new("text", "file.txt")
      subtree = Gyt::Tree.new([], "src")
      sha1 = Gyt::Tree.new([blob, subtree]).write(test_repo)

      test_repo.ls_objects.length.should == 3
    end
  end

  describe "self.build_from_dir" do
    it "includes all child files as blobs" do
      write_test_file("file1.txt", "text")
      write_test_file("file2.txt", "more text")
      tree = Gyt::Tree.build_from_dir(test_repo.dir)

      tree.children.length.should == 2
      tree.children.first.type.should == Gyt::Blob::TYPE
      tree.children.first.content.should == "text"
      tree.children.last.type.should == Gyt::Blob::TYPE
      tree.children.last.content.should == "more text"
    end

    it "includes child directories as trees" do
      write_test_file("lib/text.rb", "text")
      tree = Gyt::Tree.build_from_dir(test_repo.dir)

      tree.children.length.should == 1
      tree.children.first.type.should == Gyt::Tree::TYPE
    end

    it "stores filename info on children" do
      write_test_file("abc.txt", "text")
      write_test_file("/lib/user.rb", "User")
      tree = Gyt::Tree.build_from_dir(test_repo.dir)

      tree.children.first.name.should == "abc.txt"
      tree.children.last.name.should == "lib"
    end

    it "properly nests directories recursively" do
      write_test_file("/lib/models/user.rb", "User")
      tree = Gyt::Tree.build_from_dir(test_repo.dir)

      lib = tree.children.first
      lib.name.should == "lib"
      models = lib.children.first
      models.name.should == "models"
      user = models.children.first
      user.name.should == "user.rb"
    end
  end

  describe "to_store" do
    it "correctly formats the tree file" do
      blob = Gyt::Blob.new("text1", "file.txt")
      subtree = Gyt::Tree.new([], "src")
      tree = Gyt::Tree.new([blob, subtree])

      tree.to_store.should == "tree\0blob #{blob.sha1} file.txt\ntree #{subtree.sha1} src"
    end
  end
end
