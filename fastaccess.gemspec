$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "fastaccess/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "fastaccess"
  s.version     = Fastaccess::VERSION
  s.authors     = ["Tim Reddehase"]
  s.email       = ["robustus@rightsrestricted.com"]
  s.licenses    = ["MIT"]
  s.homepage    = "https://github.com/0robustus1/fastaccess"
  s.summary     = "allows storing of generated content via redis"
  s.description = "rails model-helper to store generated content in redis, for fastaccess"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 3.2", "< 4.1"
  s.add_dependency "redis", "~> 3.0"

  s.add_development_dependency "sqlite3", "~> 1.3"
end
