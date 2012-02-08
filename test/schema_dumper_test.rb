require 'test_helper'

class AddCommentsTest < Test::Unit::TestCase
  include TestHelper

  def test_dump
    ActiveRecord::Schema.define do
      add_table_comment :sample, "a table comment"
      add_column_comment :sample, :field1, "a \"comment\" \\ that ' needs; escaping''"
      add_column :sample, :field3, :string, :null => false, :comment => "third column comment"
    end
    dest = StringIO.new
    ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, dest)
    dest.rewind
    result = dest.read
    expected = <<EOS
# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 1) do

  create_table "sample", :force => true, :comment => "a table comment" do |t|
    t.string  "field1",                 :comment => "a \"comment\" \\ that ' needs; escaping''"
    t.integer "field2"
    t.string  "field3", :null => false, :comment => "third column comment"
  end

end
EOS
    assert_equal expected, result
  end
end
