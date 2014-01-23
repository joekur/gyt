require File.expand_path("lib/gyt")
require 'fileutils'

RSpec.configure do |config|
  config.before(:each) do
    @test_dir = File.expand_path("spec/tmp")
    Dir.mkdir(@test_dir)
  end

  config.after(:each) do
    FileUtils.rm_r(@test_dir)
  end
end

def test_repo
  @test_repo ||= Gyt::Repository.init(@test_dir)
end

def write_test_file(relative_path, content)
  full_path = File.join(test_repo.path, relative_path)
  dirname = File.dirname(full_path)
  FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
  File.write(full_path, content)
end
