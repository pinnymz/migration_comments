module MigrationComments::ActiveRecord::ConnectionAdapters
  class CommentDefinition < Struct.new(:adapter, :table, :column_name, :comment_text)
    def to_dump
      table_comment? ?
          "add_table_comment :#{table_name}, %{#{comment_text}}" :
          "add_column_comment :#{table_name}, :#{column_name}, %{#{comment_text}}"
    end

    def to_sql
      "COMMENT ON #{comment_target} IS #{escaped(comment_text)}"
    end
    alias to_s :to_sql

    def table_comment?
      column_name.blank?
    end

    def table_name
      table.respond_to?(:name) ? table.name : table
    end

    private
    def comment_target
      table_comment? ?
          "TABLE #{adapter.quote_table_name(table_name)}" :
          "COLUMN #{adapter.quote_table_name(table_name)}.#{adapter.quote_column_name(column_name)}"
    end

    def escaped(comment)
      comment.nil? ? 'NULL' : "'#{comment.gsub("'", "''")}'"
    end
  end
end