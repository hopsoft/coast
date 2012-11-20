require "rake"
require File.join(File.dirname(__FILE__), "lib", "coast", "version")

Gem::Specification.new do |spec|
  spec.name        = "coast"
  spec.version     = Coast::VERSION
  spec.summary     = "A small mixin for Rails controllers that provides restful behavior."
  spec.description = "Resourceful behavior for Rails controllers with a simple DSL."
  spec.authors     = [ "Nathan Hopkins" ]
  spec.email       = [ "natehop@gmail.com" ]
  spec.files       = FileList[
    "lib/coast.rb",
    "lib/**/*.rb",
    "Gemfile",
    "Gemfile.lock",
    "README.md",
    "LICENSE.txt"
  ]
  spec.test_files  = FileList[
    "test/**/*.rb"
  ]
  spec.homepage    ="https://github.com/hopsoft/coast"
  spec.add_dependency "activesupport"
  spec.add_development_dependency "micro_test", "0.3.0.rc4"
  spec.add_development_dependency "micro_mock", "0.0.8"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-stack_explorer"
  spec.add_development_dependency "awesome_print"
  spec.license = "MIT"
end
