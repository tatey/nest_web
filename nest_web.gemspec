require File.expand_path('../lib/nest_web/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Tate Johnson']
  gem.email         = ['tate@tatey.com']
  gem.description   = %q{Control your nest devices and structures}
  gem.summary       = %q{Control your nest devices and structures}
  gem.homepage      = "https://github.com/tatey/nest_web"
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'nest_web'
  gem.require_paths = ['lib']
  gem.version       = NestWeb::VERSION
  gem.add_dependency "excon", '~> 0.41.0'

  gem.add_development_dependency 'pry'
end
