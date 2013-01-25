$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "fastaccess/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "fastaccess"
  s.version     = Fastaccess::VERSION
  s.authors     = ["Tim Reddehase"]
  s.email       = ["robustus@rightsrestricted.com"]
  s.homepage    = "http://rightsrestricted.com/software/fastaccess"
  s.summary     = "allows storing of generated content via redis"
  s.description = "rails model-helper to store generated content in redis, for fastaccess"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.11"
  s.add_dependency "redis", "~> 3.0.2"

  s.add_development_dependency "sqlite3"
end
