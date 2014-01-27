require "spec_helper"

describe Gyt::Store do
  let(:store) { Gyt::Store.new(test_repo) }

  it "can write and retrieve data" do
    data = "this is some data"
    key = store.write(data)
    store.read(key).should == data
  end

  describe "read" do
    it "returns nil if file doesn't exist" do
      store.read("idontexist").should be_nil
    end
  end

  describe "store" do
    it "will only write one object to file if duplicate" do
      store.write("data")
      store.write("data")
      test_repo.ls_objects.length.should == 1
    end
  end

  describe "clean" do
    it "removes file from store" do
      id = store.write("data")
      test_repo.ls_objects.length.should == 1
      store.clean(id)
      test_repo.ls_objects.length.should == 0
    end
  end
end
