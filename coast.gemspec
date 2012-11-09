Gem::Specification.new do |s|
  s.name        = "coast"
  s.version     = "0.9.1"
  s.date        = "2012-04-06"
  s.summary     = "Coast"
  s.description = "Resourceful behavior for Rails controllers with a Sinatra like DSL."
  s.authors     = [ "Nathan Hopkins" ]
  s.email       = [ "nate.hop@gmail.com" ]
  s.files       = [ "lib/coast.rb" ]
  s.test_files  = [ "spec/coast_spec.rb" ]
  s.homepage    ="https://github.com/hopsoft/coast"
  
  s.add_dependency("activesupport")
  s.add_dependency("railties", "~> 3.1")
  
  s.license = "MIT"

end
