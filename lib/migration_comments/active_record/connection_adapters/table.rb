module MigrationComments::ActiveRecord::ConnectionAdapters
  module Table
    def change_comment(column_name, comment_text)
      @base.set_column_comment(@table_name || name, column_name, comment_text)
    end

    def change_table_comment(comment_text)
      @base.set_table_comment(@table_name || name, comment_text)
    end
    alias comment :change_table_comment
  end
end