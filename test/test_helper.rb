require 'minitest/autorun'

require 'rubygems'
gem 'activerecord', '>= 2.3.2'
require 'active_record'
require 'yaml'

CONFIGURATIONS = YAML::load(IO.read(File.join(File.dirname(__FILE__), 'config/database.yml')))

ENV['DB'] ||= 'postgres' # override as needed

ActiveRecord::Base.establish_connection(CONFIGURATIONS[ENV['DB']])

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'migration_comments'

module TestHelper
  def setup
    ActiveRecord::Schema.define(:version => 1) do
      create_table :sample do |t|
        t.string :field1
        t.integer :field2
      end
    end
  end

  def teardown
    ActiveRecord::Schema.define do
      drop_table :sample
    end
  end
end

class Sample < ActiveRecord::Base
  self.table_name = 'sample'
end

class Sample2 < ActiveRecord::Base
  self.table_name = 'sample2'
end
