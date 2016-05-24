module MigrationComments::ActiveRecord::ConnectionAdapters
  module Table
    def change_comment(column_name, comment_text)
      @base.set_column_comment(name, column_name, comment_text)
    end

    def change_table_comment(comment_text)
      @base.set_table_comment(name, comment_text)
    end
    alias_method :comment, :change_table_comment
  end
end