require "spec_helper"

describe Gyt::Store do
  let(:store) { Gyt::Store.new(test_repo) }

  it "can write and retrieve data" do
    data = "this is some data"
    key = store.write(data)
    store.read(key).should == data
  end
end
