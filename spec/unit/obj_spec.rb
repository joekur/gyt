require "spec_helper"

describe Gyt::Obj do
  class TestObj < Gyt::Obj
    def content
      "test_content"
    end
    def to_store
      content
    end
  end

  describe "write" do
    it "returns a sha1" do
      obj = TestObj.new
      obj.write(test_repo).should == obj.sha1
    end
  end
end
