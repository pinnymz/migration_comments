module MigrationComments::ActiveRecord::ConnectionAdapters
  class CommentDefinition < Struct.new(:table_name, :column_name, :comment_text)
    def to_dump
      table_comment? ?
          "set_table_comment :#{table_name}, %{#{comment_text}}" :
          "set_column_comment :#{table_name}, :#{column_name}, %{#{comment_text}}"
    end

    def table_comment?
      column_name.blank?
    end

  end
end