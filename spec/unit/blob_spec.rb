require "spec_helper"

describe Gyt::Blob do
  describe "self.read" do
    it "parses the blob" do
      content = "This is some content"
      sha1 = Gyt::Blob.new(content).write(test_repo)
      blob = Gyt::Blob.read(test_repo, sha1)

      blob.content.should == content
    end
  end

  describe "to_store" do
    it "correctly formats the blob file" do
      content = "This is some content"
      blob = Gyt::Blob.new(content)

      blob.to_store.should == "blob #{content.bytesize}\0This is some content"
    end
  end
end
