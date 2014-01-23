require "spec_helper"

describe Gyt::Blob do
  describe "self.save" do
    it "correctly formats the blob" do
      content = "This is some content"
      key = Gyt::Blob.save(test_repo, content)
      Gyt::Store.new(test_repo).read(key).should == "blob #{content.bytesize}\0This is some content"
    end
  end

  describe "initialize" do
    it "parses the blob" do
      content = "This is some content"
      key = Gyt::Blob.save(test_repo, content)
      blob = Gyt::Blob.new(test_repo, key)

      blob.bytesize.should == content.bytesize
      blob.content.should == content
    end
  end
end
