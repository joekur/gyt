require "spec_helper"

describe Gyt::Store do
  let(:store) { Gyt::Store.new(test_repo) }

  it "can write and retrieve data" do
    data = "this is some data"
    key = store.write(data)
    store.read(key).should == data
  end

  describe "store" do
    it "will only write one object to file" do
      store.write("data")
      store.write("data")
      test_repo.ls_objects.length.should == 1
    end
  end

  describe "clean" do
    it "removes file from store" do
      sha1 = store.write("data")
      test_repo.ls_objects.length.should == 1
      store.clean(sha1)
      test_repo.ls_objects.length.should == 0
    end
  end
end
