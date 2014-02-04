require "spec_helper"

describe Gyt::Tree do
  it "can read and write to object store" do
    blob = Gyt::Blob.new(test_repo, "text", "file.txt")
    subtree = Gyt::Tree.new(test_repo, [], "src")
    id = Gyt::Tree.new(test_repo, [blob, subtree]).write

    tree = Gyt::Tree.read(test_repo, id)
    tree.children.first.name.should == "file.txt"
    tree.children.first.content.should == "text"
    tree.children.last.name.should == "src"
    tree.children.last.children.should be_empty
  end

  describe "self.write" do
    it "writes a file for itself and all children recursively" do
      blob = Gyt::Blob.new(test_repo, "text", "file.txt")
      subtree = Gyt::Tree.new(test_repo, [], "src")
      Gyt::Tree.new(test_repo, [blob, subtree]).write

      test_repo.ls_objects.length.should == 3
    end
  end

  describe "self.build_from_dir" do
    it "includes all child files as blobs" do
      write_test_file("file1.txt", "text")
      write_test_file("file2.txt", "more text")
      tree = Gyt::Tree.build_from_dir(test_repo, test_repo.dir)

      tree.children.length.should == 2
      tree.children.first.type.should == Gyt::Blob::TYPE
      tree.children.first.content.should == "text"
      tree.children.last.type.should == Gyt::Blob::TYPE
      tree.children.last.content.should == "more text"
    end

    it "includes child directories as trees" do
      write_test_file("lib/text.rb", "text")
      tree = Gyt::Tree.build_from_dir(test_repo, test_repo.dir)

      tree.children.length.should == 1
      tree.children.first.type.should == Gyt::Tree::TYPE
    end

    it "stores filename info on children" do
      write_test_file("abc.txt", "text")
      write_test_file("/lib/user.rb", "User")
      tree = Gyt::Tree.build_from_dir(test_repo, test_repo.dir)

      tree.children.first.name.should == "abc.txt"
      tree.children.last.name.should == "lib"
    end

    it "properly nests directories recursively" do
      write_test_file("/lib/models/user.rb", "User")
      tree = Gyt::Tree.build_from_dir(test_repo, test_repo.dir)

      lib = tree.children.first
      lib.name.should == "lib"
      models = lib.children.first
      models.name.should == "models"
      user = models.children.first
      user.name.should == "user.rb"
    end

    it "stores directory name on tree" do
      write_test_file("/lib/user.rb", "User")
      dir = Gyt::Directory.new(File.join(test_repo.path, "lib"))
      tree = Gyt::Tree.build_from_dir(test_repo, dir)

      tree.name.should == "lib"
    end
  end

  describe "to_store" do
    it "correctly formats the tree file" do
      blob = Gyt::Blob.new(test_repo, "text1", "file.txt")
      subtree = Gyt::Tree.new(test_repo, [], "src")
      tree = Gyt::Tree.new(test_repo, [blob, subtree])

      tree.to_store.should == "tree\0blob #{blob.id} file.txt\ntree #{subtree.id} src"
    end
  end

  describe "merge" do
    it "includes unique files from both" do
      child_a = Gyt::Blob.new(test_repo, "hello", "file1")
      child_b = Gyt::Blob.new(test_repo, "goodbye", "file2")
      tree = Gyt::Tree.new(test_repo, [child_a])
      tree.merge([child_b])

      tree.children.should include(child_a)
      tree.children.should include(child_b)
    end

    it "includes only one copy of duplicate children" do
      blob = Gyt::Blob.new(test_repo, "hello", "file1")
      tree = Gyt::Tree.new(test_repo, [blob])
      tree.merge([blob])

      tree.children.should == [blob]
    end

    it "takes the new version when there is a duplicate" do
      child_a = Gyt::Blob.new(test_repo, "hello", "file1")
      child_b = Gyt::Blob.new(test_repo, "hello-modified", "file1")
      tree = Gyt::Tree.new(test_repo, [child_a])
      tree.merge([child_b])

      tree.children.should == [child_b]
    end
  end

  describe "children_hash" do
    it "returns a hash of all children with their names as keys" do
      blob1 = Gyt::Blob.new(test_repo, "text", "file.txt")
      blob2 = Gyt::Blob.new(test_repo, "text2", "file2.txt")
      tree = Gyt::Tree.new(test_repo, [blob1, blob2])

      tree.children_hash.should == {
        "file.txt" => blob1,
        "file2.txt" => blob2
      }
    end
  end
end
