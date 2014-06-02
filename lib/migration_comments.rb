require 'active_support/core_ext/string/inflections'
require 'active_record'
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
require 'migration_comments/active_record/connection_adapters/mysql_adapter'
require 'migration_comments/active_record/connection_adapters/mysql2_adapter'
require 'migration_comments/active_record/connection_adapters/postgresql_adapter'
require 'migration_comments/active_record/connection_adapters/abstract_sqlite_adapter'
require 'migration_comments/active_record/connection_adapters/sqlite_adapter'
require 'migration_comments/active_record/connection_adapters/sqlite3_adapter'

module MigrationComments
  def self.setup
    if ::ActiveRecord::VERSION::MAJOR == 2
      warn "[DEPRECATION] MigrationComments support for ActiveRecord v2.3 is deprecated and will be removed in a future version."
    end

    base_names = %w(SchemaDumper) +
      %w(ColumnDefinition Column Table TableDefinition AbstractAdapter).map{|name| "ConnectionAdapters::#{name}"}

    base_names.each do |base_name|
      ar_class = "ActiveRecord::#{base_name}".constantize
      mc_class = "MigrationComments::ActiveRecord::#{base_name}".constantize
      unless ar_class.ancestors.include?(mc_class)
        ar_class.__send__(:include, mc_class)
      end
    end

    # Rails 4 introduces some new models that were not previously present
    optimistic_models = []
    optimistic_models << "ActiveRecord::ConnectionAdapters::AbstractAdapter::SchemaCreation"
    optimistic_models << "ActiveRecord::ConnectionAdapters::AlterTable"
    optimistic_models.each do |model_name|
      begin
        model = model_name.constantize
        mc_class = "MigrationComments::#{model_name}".constantize
        model.module_eval do
          model.send(:include, mc_class)
        end
      rescue Exception => ex
      end
    end

    adapters = %w(PostgreSQL Mysql Mysql2)
    adapters << (::ActiveRecord::VERSION::MAJOR <= 3 ? "SQLite" : "SQLite3")
    adapters.each do |adapter|
      begin
        require("active_record/connection_adapters/#{adapter.downcase}_adapter")
        adapter_class = ('::ActiveRecord::ConnectionAdapters::' << "#{adapter}Adapter").constantize
        mc_class = ('MigrationComments::ActiveRecord::ConnectionAdapters::' << "#{adapter}Adapter").constantize
        adapter_class.module_eval do
          adapter_class.__send__(:include, mc_class)
        end
      rescue Exception => ex
      end
    end

    # annotations are not required for this gem, but if they exist they should be updated
    begin
      begin # first try to load from the 'annotate' gem
        require 'annotate/annotate_models'
      rescue Exception => ex
        # continue as it may be already accessible through a plugin
      end
      gem_class = AnnotateModels
      # don't require this until after the original AnnotateModels loads to avoid namespace confusion
      require 'migration_comments/annotate_models'
      mc_class = MigrationComments::AnnotateModels
      unless gem_class.ancestors.include?(mc_class)
        gem_class.__send__(:include, mc_class)
      end
    rescue Exception => ex
      # if we got here, don't bother installing comments into annotations
    end
  end
end

MigrationComments.setup