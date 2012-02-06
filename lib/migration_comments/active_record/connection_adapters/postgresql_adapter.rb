module MigrationComments::ActiveRecord::ConnectionAdapters
  module PostresqlAdapter
    def self.included(base)
      base.class_eval do
        alias_method_chain :add_column, :migration_comments
        alias_method_chain :change_column, :migration_comments
      end
    end

    # Set a comment on a table
    def add_table_comment(table_name, comment_text)
      execute CommentDefinition.new(table_name, nil, comment_text).to_sql
    end

    # Set a comment on a column
    def add_column_comment(table_name, column_name, comment_text)
      execute CommentDefinition.new(table_name, column_name, comment_text).to_sql
    end

    def comments_supported?
      true
    end

    def add_column_with_migration_comments(table_name, column_name, type, options = {})
      add_column_without_migration_comments(table_name, column_name, type, options)
      if options[:comment]
        add_column_comment(table_name, column_name, options[:comment])
      end
    end

    def change_column_with_migration_comments(table_name, column_name, type, options = {})
      change_column_without_migration_comments(table_name, column_name, type, options)
      if options.keys.include?(:comment)
        add_column_comment(table_name, column_name, options[:comment])
      end
    end
  end
end
