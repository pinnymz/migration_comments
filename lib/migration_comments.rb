require "migration_comments/version"
require "migration_comments/schema_formatter"

require 'migration_comments/active_record/schema_dumper'
require 'migration_comments/active_record/connection_adapters/comment_definition'
require 'migration_comments/active_record/connection_adapters/column_definition'
require 'migration_comments/active_record/connection_adapters/column'
require 'migration_comments/active_record/connection_adapters/table'
require 'migration_comments/active_record/connection_adapters/table_definition'
require 'migration_comments/active_record/connection_adapters/alter_table'
require 'migration_comments/active_record/connection_adapters/abstract_adapter'
require 'migration_comments/active_record/connection_adapters/abstract_adapter/schema_creation'
require 'migration_comments/active_record/connection_adapters/mysql2_adapter'
require 'migration_comments/active_record/connection_adapters/postgresql_adapter'
require 'migration_comments/active_record/connection_adapters/sqlite3_adapter'

module MigrationComments
  def self.setup

    base_names = %w(SchemaDumper) +
        %w(AbstractAdapter AbstractAdapter::SchemaCreation AlterTable ColumnDefinition Column Table TableDefinition).map{|name| "ConnectionAdapters::#{name}"}

    base_names.each do |base_name|
      ar_class = "ActiveRecord::#{base_name}".constantize
      mc_class = "MigrationComments::ActiveRecord::#{base_name}".constantize
      unless ar_class.descendants.include?(mc_class)
        ar_class.prepend mc_class
      end
    end

    adapters = %w(PostgreSQL Mysql2 SQLite3)
    adapters.each do |adapter|
      begin
        require("active_record/connection_adapters/#{adapter.downcase}_adapter")
        adapter_class = ('::ActiveRecord::ConnectionAdapters::' << "#{adapter}Adapter").constantize
        mc_class = ('MigrationComments::ActiveRecord::ConnectionAdapters::' << "#{adapter}Adapter").constantize
        unless adapter_class.descendants.include?(mc_class)
          adapter_class.prepend mc_class
        end
      rescue ::LoadError
      end
    end

    # annotations are not required for this gem, but if they exist they should be updated
    begin
      require 'annotate/annotate_models'
      gem_class = ::AnnotateModels
      require 'migration_comments/annotate_models'
      mc_class = MigrationComments::AnnotateModels
      unless gem_class.ancestors.include?(mc_class)
        gem_class.prepend mc_class
      end
    rescue ::LoadError
      # if we got here, don't bother installing comments into annotations
    end
  end
end

MigrationComments.setup
