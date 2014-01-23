require "spec_helper"

describe Gyt::Tree do
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
