source "http://rubygems.org"

# Specify your gem's dependencies in migration_comments.gemspec
gemspec

platform :ruby do
  gem 'pg'
  gem 'mysql2'
  gem 'sqlite3'
end

platform :jruby do
  gem 'activerecord-jdbcmysql-adapter'
  gem 'activerecord-jdbcpostgresql-adapter'
  gem 'activerecord-jdbcsqlite3-adapter'
end