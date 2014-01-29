require "spec_helper"

describe Gyt::Blob do
  describe "self.read" do
    it "parses the blob" do
      content = "This is some content"
      id = Gyt::Blob.new(test_repo, content).write
      blob = Gyt::Blob.read(test_repo, id)

      blob.content.should == content
    end
  end

  describe "to_store" do
    it "correctly formats the blob file" do
      content = "This is some content"
      blob = Gyt::Blob.new(test_repo, content)

      blob.to_store.should == "blob #{content.bytesize}\0This is some content"
    end
  end
end
