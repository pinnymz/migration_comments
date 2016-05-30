require "bundler/gem_tasks"
require "rake/testtask"

task :default => [:test]

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end

namespace :test do
  task all: [:postgres, :mysql, :sqlite]

  task :postgres do
    ENV['DB'] = 'postgres'
    puts "\n\nrunning PostgreSQL tests..."
    Rake::Task['test'].execute
  end

  task :mysql do
    ENV['DB'] = 'mysql'
    puts "\n\nrunning MySQL tests..."
    Rake::Task['test'].execute
  end

  task :sqlite do
    ENV['DB'] = 'sqlite'
    puts "\n\nrunning SQLite tests..."
    Rake::Task['test'].execute
  end
end
