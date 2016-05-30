module MigrationComments::ActiveRecord::ConnectionAdapters
  module Mysql2Adapter

    def comments_supported?
      true
    end

    def set_table_comment(table_name, comment_text)
      execute "ALTER TABLE #{quote_table_name table_name} COMMENT #{escaped_comment(comment_text)}"
    end

    def set_column_comment(table_name, column_name, comment_text)
      column = column_for(table_name, column_name)
      options = {
        comment: comment_text,
        auto_increment: !!(column.extra =~ /auto_increment/)      # MySQL adapter drops this on calls to change_column
      }
      change_column table_name, column_name, column.sql_type, options
    end

    if ::ActiveRecord::VERSION::MAJOR >= 5
      def add_sql_comment!(sql, comment)
        comment_text = comment.respond_to?(:comment_text) ? comment.comment_text : comment
        super(sql, comment_text)
      end
    end

    def retrieve_table_comment(table_name)
      select_value(table_comment_sql(table_name)).presence
    end

    def retrieve_column_comments(table_name, *column_names)
      result = select_rows(column_comment_sql(table_name, *column_names)) || []
      Hash[result.map{|row| [row[0].to_sym, row[1].presence]}]
    end

    def create_table(table_name, options={})
      local_table_definition = nil
      super(table_name, options) do |td|
        local_table_definition = td
        local_table_definition.comment = options[:comment] if options.has_key?(:comment)
        yield td if block_given?
      end
      comments = local_table_definition.collect_comments(table_name)
      comments.each do |comment_definition|
        execute_comment comment_definition
      end
    end

    def change_column(table_name, column_name, type, options={})
      unless options.keys.include?(:comment)
        options.merge!(:comment => retrieve_column_comment(table_name, column_name))
      end
      super(table_name, column_name, type, options)
    end

    def add_column_options!(sql, options)
      super(sql, options)
      if options.keys.include?(:comment)
        sql << comment_sql(CommentDefinition.new(nil, nil, options[:comment]))
      end
    end

    def comment_sql(comment_definition)
      " COMMENT #{escaped_comment(comment_definition.comment_text)}"
    end

    def execute_comment(comment_definition)
      if comment_definition.table_comment?
        set_table_comment comment_definition.table_name, comment_definition.comment_text
      else
        set_column_comment comment_definition.table_name, comment_definition.column_name, comment_definition.comment_text
      end
    end

    private
    def escaped_comment(comment)
      comment.nil? ? "''" : "'#{comment.gsub("'", "''").gsub("\\", "\\\\\\\\")}'"
    end

    def table_comment_sql(table_name)
      <<SQL
SELECT table_comment FROM INFORMATION_SCHEMA.TABLES
  WHERE table_schema = '#{database_name}'
  AND table_name = '#{table_name}'
SQL
    end

    def column_comment_sql(table_name, *column_names)
      col_matcher_sql = " AND column_name IN (#{column_names.map{|c_name| "'#{c_name}'"}.join(',')})" unless column_names.empty?
      <<SQL
SELECT column_name, column_comment FROM INFORMATION_SCHEMA.COLUMNS
  WHERE table_schema = '#{database_name}'
  AND table_name = '#{table_name}' #{col_matcher_sql}
SQL
    end

    def database_name
      @database_name ||= select_value("SELECT DATABASE()")
    end

  end
end