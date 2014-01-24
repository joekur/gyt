require "spec_helper"

describe Gyt::Index do
  let(:index) { Gyt::Index.new(test_repo) }
  subject { index }

  describe "initialize" do
    its(:objects) { should be_empty }

    it "parses index file and loads objects" do
      blob = Gyt::Blob.new("hey", "file.txt")
      index.add(blob)

      index = Gyt::Index.new(test_repo)

      index.objects.should_not be_empty
      index.objects.first.name.should == "file.txt"
    end
  end

  describe "add" do
    it "adds object to index" do
      blob = Gyt::Blob.new("text", "file.txt")
      index.add(blob)

      index.objects.should == [blob]
      index.load_objects.should == [blob]
    end

    it "stores object in store" do
      expect do
        blob = Gyt::Blob.new("text", "file.txt")
        index.add(blob)
      end.to change{ test_repo.ls_objects.length }.by(1)
    end

    it "inserts object sorted alphabetically" do
      file1 = Gyt::Blob.new("text", "zzz.txt")
      file2 = Gyt::Blob.new("text", "aaa.txt")
      file3 = Gyt::Blob.new("text", "kkk.txt")
      index.add(file1)
      index.add(file2)
      index.add(file3)

      index.objects.should == [file2, file3, file1]
    end
  end

  describe "write" do
    it "updates index file with all objects" do
      file1 = Gyt::Blob.new("text1", "file1.txt")
      file2 = Gyt::Blob.new("text2", "file2.txt")
      index.add(file1)
      index.add(file2)
      index.write

      File.readlines(index.path).length.should == 2
    end
  end
end
