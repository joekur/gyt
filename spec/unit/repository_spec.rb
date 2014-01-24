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
end
