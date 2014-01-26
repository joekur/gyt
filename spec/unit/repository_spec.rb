require "spec_helper"

describe Gyt::Repository do
  describe "init" do
    it "creates .gyt directory" do
      repo = Gyt::Repository.init(@test_dir)

      Dir.entries(repo.dir.path).should include(".gyt")
      Dir.entries(repo.gyt_path).should include("objects")
    end
  end

  describe "add" do
    it "adds file as blob to the index" do
      write_test_file("readme.md", "Gyt rools!")
      test_repo.add("readme.md")

      test_repo.staged.length.should == 1
      test_repo.staged.first.type == Gyt::Blob::TYPE
      test_repo.staged.first.content.should == "Gyt rools!"
      test_repo.staged.first.name.should == "readme.md"
    end

    it "adds directory as tree to the index" do
      write_test_file("lib/user.rb", "huehue")
      test_repo.add("lib")

      test_repo.staged.length.should == 1
      test_repo.staged.first.type == Gyt::Tree::TYPE
      test_repo.staged.first.children.length.should == 1
    end
  end

  describe "commit!" do
    it "creates a new commit" do
      write_test_file("readme.md", "Gyt rools!")
      test_repo.add("readme.md")
      sha1 = test_repo.commit!("message")

      commit = Gyt::Obj.read(test_repo, sha1)
      commit.should_not be_nil
      commit.type.should == Gyt::Commit::TYPE
    end

    it "creates a new tree from staged objects" do
      write_test_file("readme.md", "Gyt rools!")
      test_repo.add("readme.md")
      sha1 = test_repo.commit!("message")

      commit = Gyt::Obj.read(test_repo, sha1)
      commit.tree.children.first.name.should == "readme.md"
    end

    it "cleans the index" do
      write_test_file("readme.md", "Gyt rools!")
      test_repo.add("readme.md")
      test_repo.commit!("message")

      test_repo.staged.should be_empty
    end

    it "does not create a commit object if index is empty" do
      test_repo.commit!("message").should be_false
      test_repo.ls_objects.should be_empty
    end
  end
end
