require "spec_helper"

describe Gyt::Repository do
  describe "self.respository?" do
    it "is true if directory has .gyt folder" do
      Gyt::Repository.repository?(test_repo.path).should be_true
    end

    it "is false if directory has no .gyt folder" do
      Gyt::Repository.repository?('/').should be_false
    end
  end

  describe "self.new" do
    it "can be passed the subdirectory of a gyt repository" do
      dir = File.join(test_repo.path, "subdir")
      Dir.mkdir(dir)
      repo = Gyt::Repository.new(dir)

      repo.path.should == test_repo.path
    end

    it "raises error when not a gyt repository" do
      expect do
        Gyt::Repository.new('/')
      end.to raise_error("Fatal - not a gyt repository")
    end
  end

  describe "self.init" do
    it "creates .gyt directory" do
      repo = Gyt::Repository.init(@test_dir)

      Dir.entries(repo.dir.path).should include(".gyt")
      Dir.entries(repo.gyt_path).should include("objects")
      Dir.entries(repo.gyt_path).should include("index")
      Dir.entries(repo.gyt_path).should include("HEAD")
      Dir.entries(repo.gyt_path).should include("refs")
    end

    it "points head to new branch master" do
      repo = Gyt::Repository.init(@test_dir)

      File.read(File.join(repo.gyt_path, "HEAD")).should == "ref: refs/heads/master"
      repo.head.should be_nil
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
      commit = test_repo.commit!("message")

      commit.should_not be_nil
      commit.should be_instance_of(Gyt::Commit)
    end

    it "creates a new tree from staged objects" do
      write_test_file("readme.md", "Gyt rools!")
      test_repo.add("readme.md")
      commit = test_repo.commit!("message")

      commit.tree.children.first.name.should == "readme.md"
    end

    it "cleans the index" do
      write_test_file("readme.md", "Gyt rools!")
      test_repo.add("readme.md")
      test_repo.commit!("message")

      test_repo.staged.should be_empty
    end

    it "does not create a commit object if index is empty" do
      test_repo.commit!("message").should be_nil
      test_repo.ls_objects.should be_empty
    end

    it "updates the head" do
      write_test_file("readme.md", "Gyt rools!")
      test_repo.add("readme.md")
      commit = test_repo.commit!("message")

      test_repo.head.should == commit.id
    end

    it "adds current commit as its parent" do
      write_test_file("readme.md", "Gyt rools!")
      test_repo.add("readme.md")
      first_commit = test_repo.commit!("first commit")

      write_test_file("readme2.md", "Gyt rools moar!")
      test_repo.add("readme2.md")
      second_commit = test_repo.commit!("second commit")

      second_commit.parent_id.should == first_commit.id
    end
  end

  describe "log" do
    it "loops through all parent commits" do
      write_test_file("readme.md", "Gyt rools!")
      test_repo.add("readme.md")
      first_commit = test_repo.commit!("first commit")

      write_test_file("readme2.md", "Gyt rools moar!")
      test_repo.add("readme2.md")
      second_commit = test_repo.commit!("second commit")

      test_repo.log
    end

    it "outputs nothing on new repository" do
      test_repo.log
    end
  end
end
