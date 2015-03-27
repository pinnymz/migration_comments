require File.join(File.dirname(__FILE__), 'test_helper')

class AddCommentsTest < Minitest::Unit::TestCase
  include TestHelper

  def test_adding_a_table_comment
    comment_text = "a comment on the sample table"
    result = nil
    ActiveRecord::Schema.define do
      set_table_comment :sample, comment_text
      result = retrieve_table_comment :sample
    end
    assert_equal comment_text, result
  end

  def test_adding_a_column_comment
    comment_text = "a comment on the sample table in the column field"
    result_field1 = nil
    result_field2 = nil
    ActiveRecord::Schema.define do
      set_column_comment :sample, :field1, comment_text
      result_field1 = retrieve_column_comment :sample, :field1
      result_field2 = retrieve_column_comment :sample, :field2
    end
    assert_equal comment_text, result_field1
    assert_nil result_field2
  end

  def test_adding_a_column_with_a_comment
    comment_text = "a comment in a new column"
    result_field1 = nil
    result_field3 = nil
    ActiveRecord::Schema.define do
      add_column :sample, :field3, :string, :comment => comment_text
      result_field3 = retrieve_column_comment :sample, :field3
      result_field1 = retrieve_column_comment :sample, :field1
    end
    assert_equal comment_text, result_field3
    assert_nil result_field1
  end

  def test_changing_a_column_while_adding_a_comment
    comment_text = "a comment in a changing column"
    result_field1 = nil
    ActiveRecord::Schema.define do
      change_column :sample, :field1, :string, :limit => 25, :comment => comment_text
      result_field1 = retrieve_column_comment :sample, :field1
    end
    assert_equal comment_text, result_field1
  end

  def test_creating_a_table_with_table_comments_and_no_block
    ActiveRecord::Schema.define do
      create_table :sample3, :temporary => true, :comment => "a table comment"
    end
  end

  def test_creating_a_table_with_table_and_column_comments
    table_comment = "a table comment"
    column_comment = "a column comment"
    result_table_comment = nil
    result_column_comments = nil
    ActiveRecord::Schema.define do
      begin
        create_table :sample2, :comment => table_comment do |t|
          t.integer :field1, :comment => column_comment
          t.string :field2
        end
        result_table_comment = retrieve_table_comment :sample2
        result_column_comments = retrieve_column_comments :sample2
      ensure
        drop_table :sample2 rescue nil
      end
    end
    assert_equal table_comment, result_table_comment
    assert_equal column_comment, result_column_comments[:field1]
    assert_nil result_column_comments[:field2]
  end

  def test_changing_a_table_with_new_comments
    table_comment = "a table comment"
    column_comment1 = "a column comment"
    column_comment2 = "another column comment"
    result_table_comment = nil
    result_column_comments = nil
    ActiveRecord::Schema.define do
      change_table :sample do |t|
        t.comment table_comment
        t.change :field1, :text, :comment => column_comment1
        t.change :field2, :string
        t.boolean :field3, :comment => column_comment2
      end
      result_table_comment = retrieve_table_comment :sample
      result_column_comments = retrieve_column_comments :sample
    end
    assert_equal table_comment, result_table_comment
    assert_equal column_comment1, result_column_comments[:field1]
    assert_equal column_comment2, result_column_comments[:field3]
    assert_nil result_column_comments[:field2]
  end

  def test_partially_modifying_comments_from_a_table
    table_comment = "a table comment"
    column_comment1 = "a column comment"
    column_comment2 = "another column comment"
    column_comment3 = "yet a third column comment"
    modified_comment = "modified comment"
    result_table_comment = nil
    result_column_comments = nil
    ActiveRecord::Schema.define do
      change_table :sample do |t|
        t.comment table_comment
        t.change :field1, :string, :comment => column_comment1
        t.change :field2, :integer, :comment => column_comment2
        t.boolean :field3, :comment => column_comment3
      end
      change_table :sample do |t|
        t.comment nil
        t.change :field1, :text
        t.change :field2, :string, :comment => modified_comment
        t.change :field3, :boolean, :comment => nil
      end
      result_table_comment = retrieve_table_comment :sample
      result_column_comments = retrieve_column_comments :sample
    end
    assert_nil result_table_comment
    assert_equal column_comment1, result_column_comments[:field1]
    assert_equal modified_comment, result_column_comments[:field2]
    assert_nil result_column_comments[:field3]
  end

  def test_removing_comments_from_a_table
    comment_text = "a comment on the sample table"
    result = nil
    ActiveRecord::Schema.define do
      set_table_comment :sample, comment_text
      remove_table_comment :sample
      result = retrieve_table_comment :sample
    end
    assert_nil result
  end

  def test_removing_comments_from_a_column
    comment_text = "a comment on field1 of sample table"
    result = nil
    ActiveRecord::Schema.define do
      set_column_comment :sample, :field1, comment_text
      remove_column_comment :sample, :field1
      result = retrieve_column_comment :sample, :field1
    end
    assert_nil result
  end

  def test_comment_text_is_escaped_properly
    comment_text = "a \"comment\" \\ that ' needs; escaping''"
    result = nil
    ActiveRecord::Schema.define do
      set_table_comment :sample, comment_text
      result = retrieve_table_comment :sample
    end
    assert_equal comment_text, result
  end

end
