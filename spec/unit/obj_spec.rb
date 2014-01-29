require "spec_helper"

describe Gyt::Obj do
  class TestObj < Gyt::Obj
    def initialize(repo)
      @repo = repo
    end
    def content
      "test_content"
    end
    def to_store
      content
    end
  end

  describe "write" do
    it "returns a sha1 id" do
      obj = TestObj.new(test_repo)
      obj.write.should == obj.id
    end
  end

  describe "read" do
    it "returns the correct type of object based on the header type" do
      id = Gyt::Blob.new(test_repo, "").write
      Gyt::Obj.read(test_repo, id).should be_instance_of(Gyt::Blob)

      id = Gyt::Tree.new(test_repo).write
      Gyt::Obj.read(test_repo, id).should be_instance_of(Gyt::Tree)

      id = Gyt::Commit.new(test_repo, "", Gyt::Tree.new(test_repo)).write
      Gyt::Obj.read(test_repo, id).should be_instance_of(Gyt::Commit)
    end

    it "returns nil if the object doesn't exist" do
      Gyt::Obj.read(test_repo, "idontexist").should be_nil
    end
  end
end
