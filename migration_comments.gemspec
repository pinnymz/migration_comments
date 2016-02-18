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

  s.add_runtime_dependency 'activerecord', '>= 2.3.2'

  # for development, we are testing against the 'annotate' gem
  # however, the comments should work with the original 'annotate_models' plugin as well at:
  #  http://repo.pragprog.com/svn/Public/plugins/annotate_models
  # provided the environment is not loaded until _after_ the AnnotateModels module is declared
  s.add_development_dependency 'annotate', '~> 2.5.0'

  # add / replace with other adapter(s) as needed
  s.add_development_dependency 'pg'
  # s.add_development_dependency 'postgres-pr'
  # s.add_development_dependency 'mysql'
  s.add_development_dependency 'mysql2'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'test-unit', '>= 3.1.0'
end
