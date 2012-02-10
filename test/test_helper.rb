require 'test/unit'

require 'rubygems'
gem 'rails', '>= 2.3.2'
require 'active_record'
require 'yaml'

CONFIGURATIONS = YAML::load(IO.read('config/database.yml'))

ActiveRecord::Base.establish_connection(CONFIGURATIONS[ENV['DB'] || 'postgres'])

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
