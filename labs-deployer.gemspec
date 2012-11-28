# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'labs-deployer/version'

Gem::Specification.new do |gem|
  gem.name          = "labs-deployer"
  gem.version       = Labs::Deployer::VERSION
  gem.authors       = ["John Dyer"]
  gem.email         = ["johntdyer@gmail.com"]
  gem.description   = %q{Thor tasks to package chef solo cookbooks}
  gem.summary       = %q{Deployed cookbooks to s3}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]



    gem.add_dependency('s3')
    gem.add_dependency('thor')

end
