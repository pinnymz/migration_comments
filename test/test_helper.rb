$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

ActiveRecord::Base.establish_connection(
    :adapter => "postgresql",
    :database => "migration_comments_test",
    :host => "127.0.0.1",
    :username => "postgres",
    :password => "postgres"
)

ActiveRecord::Schema.define(:version => 1) do
  create_table :posts do |t|
    t.string :title
    t.text :excerpt, :body
  end
end
