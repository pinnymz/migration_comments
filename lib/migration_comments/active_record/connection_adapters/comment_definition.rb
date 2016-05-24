module MigrationComments::ActiveRecord::ConnectionAdapters
  class CommentDefinition < Struct.new(:table_name, :column_name, :comment_text)
    def to_dump
      table_comment? ?
          "set_table_comment :#{table_name}, %{#{comment_text}}" :
          "set_column_comment :#{table_name}, :#{column_name}, %{#{comment_text}}"
    end

    def to_sql
      adapter.comment_sql(self)
    end
    alias_method :to_s, :to_sql

    def table_comment?
      column_name.blank?
    end

    private

    def adapter
      ActiveRecord::Base.connection
    end
  end
end