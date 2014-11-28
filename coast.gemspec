require File.join(File.dirname(__FILE__), "lib", "coast", "version")

Gem::Specification.new do |gem|
  gem.name        = "coast"
  gem.license     = "MIT"
  gem.version     = Coast::VERSION
  gem.summary     = "A small mixin for Rails controllers that provides restful behavior."
  gem.description = "A small mixin for Rails controllers that provides restful behavior."
  gem.authors     = ["Nathan Hopkins"]
  gem.email       = ["natehop@gmail.com"]
  gem.files       = Dir["lib/**/*.rb", "[A-Z].*"]
  gem.test_files  = Dir["test/**/*.rb"]
  gem.homepage    = "https://github.com/hopsoft/coast"

  gem.add_dependency "activesupport"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "pry"
  gem.add_development_dependency "pry-stack_explorer"
  gem.add_development_dependency "pry-rescue"
  gem.add_development_dependency "pry-test"
  gem.add_development_dependency "spoof"
  gem.add_development_dependency "coveralls"
end
