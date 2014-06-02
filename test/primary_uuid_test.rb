require File.join(File.dirname(__FILE__), 'test_helper')

class PrimaryUuidTest < Minitest::Unit::TestCase
  include TestHelper

  def test_rails_4_uuid
    return unless ENV['DB'] == 'postgres' && ActiveRecord::VERSION::MAJOR >= 4
    uuid = nil
    ActiveRecord::Schema.define do
      begin
        enable_extension 'uuid-ossp'
        create_table :sample2, id: :uuid do |t|
          t.integer :field1
          t.string :field2
        end
        uuid = Sample2.create(field1: 1, field2: 'foo').id
      ensure
        drop_table :sample2 rescue nil
      end
    end
    assert_match /[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}/i, uuid
  end
end