require 'test/unit'

require 'rubygems'
gem 'activerecord', '>= 2.3.2'
require 'active_record'

ActiveRecord::Base.establish_connection(
    :adapter => "postgresql",
    :database => "migration_comments_test",
    :host => "127.0.0.1",
    :username => "postgres",
    :password => "postgres"
)

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'migration_comments'

module TestHelper
  def setup
    ActiveRecord::Schema.define do
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
