require 'test_helper'

class Sample < ActiveRecord::Base
  self.table_name = 'sample'
end

class MysqlSchemaTest < Test::Unit::TestCase
  include TestHelper

  def test_mysql_schema
    if ENV['DB'] == 'mysql'
      auto_increment = nil
      ActiveRecord::Base.connection.instance_eval do
        execute_and_free("SHOW FULL FIELDS FROM #{quote_table_name('sample')}") do |result|
          each_hash(result).map do |field|
            auto_increment = field[:Extra] if field[:Field] == 'id'
          end
        end
      end
      assert_match /auto_increment/i, auto_increment
    end

    assert_nothing_raised ActiveRecord::StatementInvalid do
      3.times do |n|
        Sample.create(:field1 => "text#{n}", :field2 => n)
      end
    end

    assert_equal Sample.count, 3
  end
end
