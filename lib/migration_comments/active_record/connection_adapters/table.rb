module MigrationComments::ActiveRecord::ConnectionAdapters
  module Table
    def change_comment(column_name, comment_text)
      @base.add_column_comment(@table_name, column_name, comment_text)
    end

    def change_table_comment(comment_text)
      @base.add_table_comment(@table_name, comment_text)
    end
    alias comment :change_table_comment
  end
end