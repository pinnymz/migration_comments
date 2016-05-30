require File.join(File.dirname(__FILE__), 'test_helper')

class SchemaDumperTest < Minitest::Test
  include TestHelper
  include MigrationComments::SchemaFormatter

  def test_dump
    ActiveRecord::Schema.define do
      set_table_comment :sample, "a table comment"
      set_column_comment :sample, :field1, "a \"comment\" \\ that ' needs; escaping''"
      add_column :sample, :field3, :string, :null => false, :default => "", :comment => "third column comment"
    end
    dest = StringIO.new
    ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, dest)
    dest.rewind
    result = dest.read
    expected = if ENV['DB'] == 'mysql' && ::ActiveRecord::VERSION::MAJOR >= 5
      <<-EOS
  create_table "sample", force: :cascade, options: __OPTIONS__, comment: "a table comment" do |t|
    t.string  "field1",                           #{render_kv_pair(:comment, %{a \"comment\" \\ that ' needs; escaping''})}
    t.integer "field2"
    t.string  "field3", #{render_kv_pair(:default, "")}, #{render_kv_pair(:null, false)}, #{render_kv_pair(:comment, "third column comment")}
  end
      EOS
    elsif ENV['DB'] == 'mysql'
      <<-EOS
  create_table "sample", force: :cascade, comment: "a table comment" do |t|
    t.string  "field1", #{render_kv_pair(:limit, 255)},                           #{render_kv_pair(:comment, %{a \"comment\" \\ that ' needs; escaping''})}
    t.integer "field2", #{render_kv_pair(:limit, 4)}
    t.string  "field3", #{render_kv_pair(:limit, 255)}, #{render_kv_pair(:default, "")}, #{render_kv_pair(:null, false)}, #{render_kv_pair(:comment, "third column comment")}
  end
      EOS
    else
      <<-EOS
  create_table "sample", force: :cascade, comment: "a table comment" do |t|
    t.string  "field1",                           #{render_kv_pair(:comment, %{a \"comment\" \\ that ' needs; escaping''})}
    t.integer "field2"
    t.string  "field3", #{render_kv_pair(:default, "")}, #{render_kv_pair(:null, false)}, #{render_kv_pair(:comment, "third column comment")}
  end
      EOS
    end
    assert_match(/#{Regexp.escape(expected).gsub(/__OPTIONS__/, %Q("ENGINE=InnoDB[^"]*"))}/, result)
  end

  def test_dump_with_no_columns
    ActiveRecord::Schema.define do
      remove_column :sample, :field1
      remove_column :sample, :field2
      set_table_comment :sample, "a table comment"
    end
    dest = StringIO.new
    ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, dest)
    dest.rewind
    result = dest.read
    expected = if ENV['DB'] == 'mysql' && ::ActiveRecord::VERSION::MAJOR >= 5
      <<-EOS
  create_table "sample", force: :cascade, options: __OPTIONS__, comment: "a table comment" do |t|
      EOS
    else
      <<-EOS
  create_table "sample", force: :cascade, comment: "a table comment" do |t|
  end
      EOS
    end

    assert_match(/#{Regexp.escape(expected).gsub(/__OPTIONS__/, %Q("ENGINE=InnoDB[^"]*"))}/, result)
  end

  def test_schema_dump_with_custom_type_error_for_pg
    return unless ENV['DB'] == 'postgres'
    ActiveRecord::Base.connection.execute "DROP TYPE IF EXISTS my_custom_type; CREATE TYPE my_custom_type AS ENUM('thing1', 'thing2');"
    ActiveRecord::Base.connection.execute "ALTER TABLE sample ALTER COLUMN field2 TYPE my_custom_type USING 'thing1';"

    ActiveRecord::Schema.define do
      set_table_comment :sample, "a table comment"
      set_column_comment :sample, :field1, "column comment"
    end

    dest = StringIO.new
    ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, dest)
    dest.rewind
    result = dest.read

    expected = <<EOS
# Could not dump table "sample" because of following StandardError
#   Unknown type 'my_custom_type' for column 'field2'
EOS

    assert_match(/#{Regexp.escape expected}/, result)
  end
end
