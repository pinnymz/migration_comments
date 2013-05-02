module MigrationComments::ActiveRecord::ConnectionAdapters
  module AlterTable
    def self.included(base)
      base.class_eval do
        alias_method_chain :add_column, :migration_comments
      end
    end

    def add_column_with_migration_comments(name, type, options)
      add_column_without_migration_comments(name, type, options)
      if options.keys.include?(:comment)
        column = @adds.last
        column.comment = CommentDefinition.new(nil, @td, name, options[:comment])
      end
    end
  end
end