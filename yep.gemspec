$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'yep/version'

Gem::Specification.new do |s|
  s.name     = 'yep'
  s.version  = Yep::VERSION
  s.authors  = ['Dan Watson']
  s.email    = ['dan@paz.am']
  s.homepage = 'https://github.com/dan-watson/yep'
  s.summary  = 'Yep is a dependency injection framework written in ruby'

  s.rubyforge_project = 'yep'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`
    .split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']
end
