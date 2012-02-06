module MigrationComments::ActiveRecord::ConnectionAdapters
  module AbstractAdapter
    def self.included(base)
      base.class_eval do
        alias_method_chain :create_table, :migration_comments
      end
    end

    def create_table_with_migration_comments(*args, &block)
      local_table_definition = nil
      create_table_without_migration_comments(*args) do |td|
        block.call(td)
        local_table_definition = td
      end
      return unless comments_supported?
      table_name = args[0]
      comments = local_table_definition.collect_comments(table_name)
      comments.each do |comment_definition|
        execute comment_definition.to_sql
      end
    end

    def add_table_comment(table_name, comment_text)
      # SQL standard doesn't support schema commenting
      raise "Table comments are not supported"
    end
    alias comment_table :add_table_comment

    def add_column_comment(table_name, column_name, comment_text)
      # SQL standard doesn't support schema commenting
      raise "Column comments are not supported"
    end
    alias comment_column :add_column_comment

    def comments_supported?
      false
    end

    # Remove a comment on a table (if set)
    def remove_table_comment(table_name)
      add_table_comment(table_name, nil)
    end

    # Remove a comment on a column (if set)
    def remove_column_comment(table_name, column_name)
      add_column_comment(table_name, column_name, nil)
    end
  end
end
