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
