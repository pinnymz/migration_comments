# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "migration_comments/version"

Gem::Specification.new do |s|
  s.name        = "migration_comments"
  s.version     = MigrationComments::VERSION
  s.authors     = ["Pinny"]
  s.email       = ["pinny@medwiztech.com"]
  s.homepage    = ""
  s.summary     = %q{Comments for your migrations}
  s.description = %q{Add schema comments in your migrations, see them in model annotations and db/schema.rb dump}

  s.rubyforge_project = "migration_comments"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'rails', '~> 2.3', '>= 2.3.2'
  s.add_runtime_dependency 'annotate'
  s.add_development_dependency 'postgres-pr'

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
