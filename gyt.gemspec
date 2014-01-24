Gem::Specification.new do |s|
  s.name        = 'gyt'
  s.version     = '0.0.0'
  s.date        = '2014-01-20'
  s.summary     = "A git clone in ruby"
  s.description = "A git clone in ruby"
  s.authors     = ["Joe Kurleto"]
  s.email       = 'joedoku@gmail.com'
  s.license     = 'MIT'

  s.add_dependency 'thor'
  s.add_development_dependency 'rspec'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
