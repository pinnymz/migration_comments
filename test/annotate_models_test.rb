require File.join(File.dirname(__FILE__), 'test_helper')
gem 'annotate'
require 'annotate/annotate_models'

class Sample < ActiveRecord::Base
  self.table_name = 'sample'
end

class AnnotateModelsTest < Minitest::Test
  include TestHelper

  TEST_PREFIX = "== Schema Information"

  def test_annotate_includes_comments
    ActiveRecord::Schema.define do
      set_table_comment :sample, "a table comment\n(multiple lines)\n"
      set_column_comment :sample, :field1, "a \"comment\" \\ that ' needs; escaping''"
      add_column :sample, :field3, :string, :null => false, :default => '', :comment => "third column comment\n(multiple lines)\n"
    end

    result = AnnotateModels.get_schema_info(Sample, TEST_PREFIX)

    string_token = ENV['DB'] == 'mysql' ? ':string(255)' : ':string     '
    token_spaces = " " * string_token.length

    expected = <<EOS
# #{TEST_PREFIX}
#
# Table name: sample # a table comment
#                    # (multiple lines)
#
#  id     :integer          not null, primary key
#  field1 #{string_token}                            # a "comment" \\ that ' needs; escaping''
#  field2 :integer
#  field3 #{string_token}      default(""), not null # third column comment
#         #{token_spaces}                            # (multiple lines)
#
EOS
    assert_equal expected, result
  end
end
