module MigrationComments::ActiveRecord::ConnectionAdapters::AbstractAdapter
  module SchemaCreation
    def column_options(o)
      column_options = super(o)
      column_options[:comment] = o.comment.comment_text if o.comment
      column_options
    end

    def add_column_options!(sql, options)
      sql = super(sql, options)
      if options.keys.include?(:comment) && !@conn.independent_comments?
        comment_definition = MigrationComments::ActiveRecord::ConnectionAdapters::CommentDefinition.new(nil, nil, options[:comment])
        sql << @conn.comment_sql(comment_definition)
      end
      sql
    end

    def visit_TableDefinition(o)
      if @conn.inline_comments?
        create_sql = "CREATE#{' TEMPORARY' if o.temporary} TABLE "
        create_sql << "#{quote_table_name(o.name)}#{@conn.comment_sql(o.table_comment)} ("
        create_sql << o.columns.map { |c| accept c }.join(', ')
        create_sql << ") #{o.options}"
        create_sql
      else
        super(o)
      end
    end

    def visit_ColumnDefinition(o)
      if @conn.inline_comments? && o.type.to_sym == :primary_key
        sql_type = type_to_sql(o.type.to_sym, o.limit, o.precision, o.scale)
        column_sql = "#{quote_column_name(o.name)} #{sql_type}"
        add_column_options!(column_sql, column_options(o))
        column_sql
      else
        super(o)
      end
    end
  end
end