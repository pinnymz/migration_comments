module MigrationComments::ActiveRecord::ConnectionAdapters
  class CommentDefinition < Struct.new(:adapter, :table, :column_name, :comment_text)
    def to_dump
      table_comment? ?
          "set_table_comment :#{table_name}, %{#{comment_text}}" :
          "set_column_comment :#{table_name}, :#{column_name}, %{#{comment_text}}"
    end

    def to_sql
      adapter.comment_sql(self)
    end
    alias to_s :to_sql

    def table_comment?
      column_name.blank?
    end

    def table_name
      table.respond_to?(:name) ? table.name : table
    end
  end
end