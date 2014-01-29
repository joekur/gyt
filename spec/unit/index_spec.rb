require "spec_helper"

describe Gyt::Index do
  let(:index) { Gyt::Index.new(test_repo) }
  subject { index }

  describe "initialize" do
    its(:objects) { should be_empty }

    it "parses index file and loads objects" do
      blob = Gyt::Blob.new(test_repo, "hey", "file.txt")
      index.add(blob)

      index = Gyt::Index.new(test_repo)

      index.objects.should_not be_empty
      index.objects.first.name.should == "file.txt"
    end
  end

  describe "add" do
    it "adds object to index" do
      blob = Gyt::Blob.new(test_repo, "text", "file.txt")
      index.add(blob)

      index.objects.should == [blob]
      index.load_objects.should == [blob]
    end

    it "stores object in store" do
      expect do
        blob = Gyt::Blob.new(test_repo, "text", "file.txt")
        index.add(blob)
      end.to change{ test_repo.ls_objects.length }.by(1)
    end

    it "inserts object sorted alphabetically" do
      obj1 = Gyt::Blob.new(test_repo, "text", "zzz.txt")
      obj2 = Gyt::Tree.new(test_repo, [], "aaa")
      obj3 = Gyt::Blob.new(test_repo, "text", "kkk.txt")
      index.add(obj1)
      index.add(obj2)
      index.add(obj3)

      index.objects.should == [obj2, obj3, obj1]
    end
  end

  describe "clean" do
    it "removes all objects from index" do
      index = Gyt::Index.new(test_repo)
      index.add(Gyt::Blob.new(test_repo, "text", "file.txt"))
      index.clean

      puts index.objects
      index.objects.should be_empty
    end
  end

  describe "write" do
    it "updates index file with all objects" do
      file1 = Gyt::Blob.new(test_repo, "text1", "file1.txt")
      file2 = Gyt::Blob.new(test_repo, "text2", "file2.txt")
      index.add(file1)
      index.add(file2)
      index.write

      File.readlines(index.path).length.should == 2
    end
  end
end
