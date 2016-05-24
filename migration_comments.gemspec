# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "migration_comments/version"

Gem::Specification.new do |s|
  s.name        = "migration_comments"
  s.version     = MigrationComments::VERSION
  s.authors     = ["Pinny"]
  s.email       = ["pinny@mwitz.com"]
  s.homepage    = "https://github.com/pinnymz/migration_comments"
  s.summary     = %q{Comments for your migrations}
  s.description = %q{Add schema comments in your migrations, see them in model annotations and db/schema.rb dump}

  s.rubyforge_project = "migration_comments"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'activerecord', '>= 4.2.0'

  s.add_development_dependency 'annotate', '~> 2.7.0'
  s.add_development_dependency 'pg'
  s.add_development_dependency 'mysql2'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'minitest-byebug'
end
