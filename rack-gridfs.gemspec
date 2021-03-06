# -*- encoding: utf-8 -*-
require File.expand_path("../lib/rack/gridfs/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "rack-gridfs"
  s.version     = Rack::GridFS::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Blake Carlson', 'Ches Martin']
  s.email       = ['blake@coin-operated.net', 'ches@whiskeyandgrits.net']
  s.homepage    = "http://github.com/skinandbones/rack-gridfs"
  s.summary     = "Serve MongoDB GridFS files from Rack"
  s.description = "Rack middleware for creating HTTP endpoints for files stored in MongoDB's GridFS"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "rack-gridfs"

  s.add_dependency('bson', '~> 1.2')
  s.add_dependency('rack')
  s.add_dependency('mongo', '~> 1.2')
  s.add_dependency('mime-types')

  s.add_development_dependency('minitest', '~> 5.8')
  s.add_development_dependency('mocha', '~> 1.1')
  s.add_development_dependency('rack-test')
  s.add_development_dependency('shoulda-context', '~> 1.2')

  s.files        = Dir.glob("lib/**/*") + %w(LICENSE README.md Rakefile)
  s.require_path = 'lib'

  s.extra_rdoc_files = [
    "CHANGES.md",
    "LICENSE",
    "README.md"
  ]
end

