module MigrationComments::ActiveRecord::ConnectionAdapters
  module AbstractAdapter
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
