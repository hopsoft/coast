require File.join(File.dirname(__FILE__), "lib", "coast", "version")

Gem::Specification.new do |spec|
  spec.name        = "coast"
  spec.license     = "MIT"
  spec.version     = Coast::VERSION
  spec.summary     = "A small mixin for Rails controllers that provides restful behavior."
  spec.description = "A small mixin for Rails controllers that provides restful behavior."
  spec.authors     = ["Nathan Hopkins"]
  spec.email       = ["natehop@gmail.com"]
  spec.files       = Dir["lib/**/*.rb", "[A-Z].*"]
  spec.test_files  = Dir["test/**/*.rb"]
  spec.homepage    = "https://github.com/hopsoft/coast"

  spec.add_dependency "activesupport"

  spec.add_development_dependency "micro_test"
  spec.add_development_dependency "micro_mock"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-stack_explorer"
  spec.add_development_dependency "awesome_print"
end
