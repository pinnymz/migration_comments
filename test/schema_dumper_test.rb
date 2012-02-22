require 'test_helper'

class SchemaDumperTest < Test::Unit::TestCase
  include TestHelper

  def test_dump
    db_type = :default
    ActiveRecord::Schema.define do
      db_type = :sqlite if connection.is_a?(ActiveRecord::ConnectionAdapters::SQLiteAdapter) rescue false

      add_table_comment :sample, "a table comment"
      add_column_comment :sample, :field1, "a \"comment\" \\ that ' needs; escaping''"
      add_column :sample, :field3, :string, :null => false, :default => "", :comment => "third column comment"
    end
    dest = StringIO.new
    ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, dest)
    dest.rewind
    result = dest.read
    expected = <<EOS
ActiveRecord::Schema.define(:version => 1) do

  create_table "sample", :force => true, :comment => "a table comment" do |t|
    t.string  "field1",                                 :comment => "a \"comment\" \\ that ' needs; escaping''"
    t.integer "field2"
    t.string  "field3", :default => "", :null => false, :comment => "third column comment"
  end

end
EOS

    assert_match /#{Regexp.escape expected}/, result
  end
end
