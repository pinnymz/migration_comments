require "migration_comments/version"

require 'migration_comments/active_record/base'
require 'migration_comments/active_record/schema'
require 'migration_comments/active_record/schema_dumper'
require 'migration_comments/active_record/connection_adapters/comment_definition'
require 'migration_comments/active_record/connection_adapters/column_definition'
require 'migration_comments/active_record/connection_adapters/table'
require 'migration_comments/active_record/connection_adapters/table_definition'
require 'migration_comments/active_record/connection_adapters/abstract_adapter'
require 'migration_comments/active_record/connection_adapters/postgresql_adapter'

module MigrationComments
  def self.setup
    base_names = %w(Base Schema SchemaDumper) +
      %w(ColumnDefinition Table TableDefinition AbstractAdapter).map{|name| "ConnectionAdapters::#{name}"}

    base_names.each do |base_name|
      ar_class = "ActiveRecord::#{base_name}".constantize
      mc_class = "MigrationComments::ActiveRecord::#{base_name}".constantize
      unless ar_class.ancestors.include?(mc_class)
        ar_class.__send__(:include, mc_class)
      end
    end

    %w(PostgreSQL).each do |adapter|
      begin
        require("active_record/connection_adapters/#{adapter.downcase}_adapter")
        adapter_class = ('ActiveRecord::ConnectionAdapters::' << "#{adapter}Adapter").constantize
        mc_class = ('MigrationComments::ActiveRecord::ConnectionAdapters::' << "#{adapter}Adapter").constantize
        adapter_class.module_eval do
          adapter_class.__send__(:include, mc_class)
        end
      rescue Exception => ex
      end
    end
  end
end