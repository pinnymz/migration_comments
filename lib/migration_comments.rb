require "migration_comments/version"

module MigrationComments
  # Your code goes here...
end

#ActiveRecord::Base.send(:include, MigrationComments::ActiveRecord::Base)
#ActiveRecord::Schema.send(:include, MigrationComments::ActiveRecord::Schema)
#ActiveRecord::SchemaDumper.send(:include, MigrationComments::ActiveRecord::SchemaDumper)
ActiveRecord::ConnectionAdapters::Table.send(:include, MigrationComments::ActiveRecord::ConnectionAdapters::Table)
ActiveRecord::ConnectionAdapters::TableDefinition.send(:include, MigrationComments::ActiveRecord::ConnectionAdapters::TableDefinition)
ActiveRecord::ConnectionAdapters::Column.send(:include, MigrationComments::ActiveRecord::ConnectionAdapters::Column)
ActiveRecord::ConnectionAdapters::ColumnDefinition.send(:include, MigrationComments::ActiveRecord::ConnectionAdapters::ColumnDefinition)
ActiveRecord::ConnectionAdapters::AbstractAdapter.send(:include, MigrationComments::ActiveRecord::ConnectionAdapters::AbstractAdapter)
ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.send(:include, MigrationComments::ActiveRecord::ConnectionAdapters::PostgresqlAdapter)
