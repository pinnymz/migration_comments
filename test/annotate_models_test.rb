require 'test_helper'
gem 'annotate'
require 'annotate/annotate_models'

class Sample < ActiveRecord::Base
  self.table_name = 'sample'
end

class AnnotateModelsTest < Test::Unit::TestCase
  include TestHelper

  TEST_PREFIX = "== Schema Information"

  def test_annotate_includes_comments
    db_type = :default
    ActiveRecord::Schema.define do
      db_type = :postgres if connection.is_a?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter) rescue false

      add_table_comment :sample, "a table comment"
      add_column_comment :sample, :field1, "a \"comment\" \\ that ' needs; escaping''"
      add_column :sample, :field3, :string, :null => false, :comment => "third column comment"
    end

    result = AnnotateModels.get_schema_info(Sample, TEST_PREFIX)
    postgres_expected = <<EOS
# #{TEST_PREFIX}
#
# Table name: sample # a table comment
#
#  id     :integer         not null, primary key
#  field1 :string(255)                           # a "comment" \\ that ' needs; escaping''
#  field2 :integer
#  field3 :string(255)     not null              # third column comment
#

EOS
    default_expected = <<EOS
# #{TEST_PREFIX}
#
# Table name: sample # a table comment
#
#  id     :integer(4)      not null, primary key
#  field1 :string(255)                           # a "comment" \\ that ' needs; escaping''
#  field2 :integer(4)
#  field3 :string(255)     not null              # third column comment
#

EOS
    expected = instance_eval "#{db_type}_expected"
    assert_equal expected, result
  end
end

