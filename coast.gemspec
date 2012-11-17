require "rake"
require File.join(File.dirname(__FILE__), "lib", "coast", "version")

Gem::Specification.new do |s|
  s.name        = "coast"
  s.version     = Coast::VERSION
  s.summary     = "Coast"
  s.description = "Resourceful behavior for Rails controllers with a simple DSL."
  s.authors     = [ "Nathan Hopkins" ]
  s.email       = [ "natehop@gmail.com" ]
  s.files       = FileList[
    "lib/coast.rb",
    "lib/**/*.rb",
    "LICENSE.txt",
    "README.md"
  ]
  s.test_files  = FileList[
    "test/**/*.rb"
  ]
  s.homepage    ="https://github.com/hopsoft/coast"
  s.add_dependency("activesupport")
  s.license = "MIT"
end
