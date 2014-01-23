require "spec_helper"

describe Gyt::Repository do
  describe "init" do
    it "creates .gyt directory" do
      repo = Gyt::Repository.init(@test_dir)

      Dir.entries(repo.dir.path).should include(".gyt")
      Dir.entries(repo.gyt_path).should include("objects")
    end
  end
end
