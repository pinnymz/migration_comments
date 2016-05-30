module MigrationComments::ActiveRecord::ConnectionAdapters
  module PostgreSQLAdapter

    def comments_supported?
      true
    end

    def independent_comments?
      true
    end

    # Set a comment on a table
    def set_table_comment(table_name, comment_text)
      execute comment_sql(CommentDefinition.new(table_name, nil, comment_text))
    end

    # Set a comment on a column
    def set_column_comment(table_name, column_name, comment_text)
      execute comment_sql(CommentDefinition.new(table_name, column_name, comment_text))
    end

    if ::ActiveRecord::VERSION::MAJOR >= 5
      def change_column_comment(table_name, column_name, comment)
        comment_text = comment.respond_to?(:comment_text) ? comment.comment_text : comment
        super(table_name, column_name, comment_text)
      end
    end

    def retrieve_table_comment(table_name)
      select_value(table_comment_sql(table_name)).presence
    end

    def retrieve_column_comments(table_name, *column_names)
      result = select_rows(column_comment_sql(table_name, *column_names))
      Hash[result.map{|row| [row[0].to_sym, row[1].presence]}]
    end

    def create_table(table_name, options = {})
      local_table_definition = nil
      super(table_name, options) do |td|
        local_table_definition = td
        local_table_definition.comment = options[:comment] if options.has_key?(:comment)
        yield td if block_given?
      end
      comments = local_table_definition.collect_comments(table_name)
      comments.each do |comment_definition|
        execute comment_sql(comment_definition)
      end
    end

    def add_column(table_name, column_name, type, options = {})
      super(table_name, column_name, type, options)
      if options[:comment]
        set_column_comment(table_name, column_name, options[:comment])
      end
    end

    def change_column(table_name, column_name, type, options = {})
      super(table_name, column_name, type, options)
      if options.keys.include?(:comment)
        set_column_comment(table_name, column_name, options[:comment])
      end
    end

    def comment_sql(comment_definition)
      "COMMENT ON #{comment_target(comment_definition)} IS #{escaped_comment(comment_definition.comment_text)}"
    end

    private

    private
    def comment_target(comment_definition)
      comment_definition.table_comment? ?
          "TABLE #{quote_table_name(comment_definition.table_name)}" :
          "COLUMN #{quote_table_name(comment_definition.table_name)}.#{quote_column_name(comment_definition.column_name)}"
    end

    def escaped_comment(comment)
      comment.nil? ? 'NULL' : "'#{comment.gsub("'", "''")}'"
    end

    def table_comment_sql(table_name)
      <<SQL
SELECT d.description FROM (
#{table_oids(table_name)}) tt
JOIN pg_catalog.pg_description d
  ON tt.oid = d.objoid AND tt.tableoid = d.classoid AND d.objsubid = 0;
SQL
    end

    def column_comment_sql(table_name, *column_names)
      col_matcher_sql = column_names.empty? ? "" : " a.attname IN (#{column_names.map{|c_name| "'#{c_name}'"}.join(',')}) AND "
      <<SQL
SELECT a.attname, pg_catalog.col_description(a.attrelid, a.attnum)
FROM pg_catalog.pg_attribute a
JOIN (
#{table_oids(table_name)}) tt
  ON tt.oid = a.attrelid
WHERE #{col_matcher_sql} a.attnum > 0 AND NOT a.attisdropped;
SQL
    end

    def table_oids(table_name)
      <<SQL
SELECT c.oid, c.tableoid
FROM pg_catalog.pg_class c
WHERE c.relname = '#{table_name}'
  AND c.relkind = 'r'
  AND pg_catalog.pg_table_is_visible(c.oid)
SQL
    end
  end
end
