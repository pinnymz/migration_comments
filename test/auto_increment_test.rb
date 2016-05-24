require File.join(File.dirname(__FILE__), 'test_helper')

class Sample < ActiveRecord::Base
  self.table_name = 'sample'
end

class AutoIncrementTest < Minitest::Test
  include TestHelper

  def test_basic_table_creation
    assert_auto_increments
  end

  def test_modified_primary_key_with_auto_increment
    comment_text = "a comment on the sample table in the primary_key field"
    result_comment = nil
    ActiveRecord::Schema.define do
      set_column_comment :sample, :id, comment_text
      result_comment = retrieve_column_comment :sample, :id
    end
    assert_auto_increments
    assert_equal comment_text, result_comment
  end

  def test_modified_primary_key_without_auto_increment
    comment_text = "a comment on the sample table in the primary_key field"
    result_comment = nil
    ActiveRecord::Schema.define do
      change_column :sample, :id, :integer, auto_increment: false
      set_column_comment :sample, :id, comment_text
      result_comment = retrieve_column_comment :sample, :id
    end
    assert_does_not_auto_increment
    assert_equal comment_text, result_comment
  end

  private

  def assert_does_not_auto_increment
    if ENV['DB'] == 'mysql'
      extra = extract_extra_attributes('id')
      refute_match(/auto_increment/i, extra)
    end

    id = nil
    ActiveRecord::Base.connection.instance_eval do
      execute "INSERT INTO #{quote_table_name :sample} (#{quote_column_name :id}, #{quote_column_name :field1}, #{quote_column_name :field2}) VALUES (15, 'text3', 11)"
      id = select_value("SELECT #{quote_column_name :id} FROM #{quote_table_name :sample}").to_i
    end
    assert_equal 15, id
  end

  def assert_auto_increments
    if ENV['DB'] == 'mysql'
      extra = extract_extra_attributes('id')
      assert_match(/auto_increment/i, extra)
    end

    ids = []
    ActiveRecord::Base.connection.instance_eval do
      3.times do |n|
        execute "INSERT INTO #{quote_table_name :sample} (#{quote_column_name :field1}, #{quote_column_name :field2}) VALUES ('text#{n}', #{n})"
      end
      ids = select_rows("SELECT #{quote_column_name :id} FROM #{quote_table_name :sample}").map{|r| r.first.to_i }.sort
    end
    assert_equal [1,2,3], ids

    assert_equal Sample.count, 3
  end

  def extract_extra_attributes(field_name)
    ActiveRecord::Base.connection.instance_eval do
      execute_and_free("SHOW FULL FIELDS FROM #{quote_table_name :sample}") do |result|
        each_hash(result).detect{|field| field[:Field] == field_name}[:Extra]
      end
    end
  end
end