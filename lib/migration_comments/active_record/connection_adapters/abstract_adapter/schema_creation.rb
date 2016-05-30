module MigrationComments::ActiveRecord::ConnectionAdapters::AbstractAdapter
  module SchemaCreation
    def column_options(o)
      column_options = super(o)
      column_options[:comment] = o.comment.comment_text if o.comment.respond_to?(:comment_text)
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
        create_sql << "#{quote_table_name(o.name)}#{@conn.comment_sql(o.comment)} ("
        create_sql << o.columns.map { |c| accept c }.join(', ')
        create_sql << ") #{o.options}"
        create_sql
      else
        super(o)
      end
    end

    def visit_ColumnDefinition(o)
      if @conn.inline_comments? && o.type.to_sym == :primary_key && o.comment
        if ::ActiveRecord::VERSION::MAJOR >= 5
          comment_sql = super(o)
          comment_sql << @conn.comment_sql(o.comment)
        else
          sql_type = type_to_sql(o.type.to_sym, o.limit, o.precision, o.scale)
          column_sql = "#{quote_column_name(o.name)} #{sql_type}"
          add_column_options!(column_sql, column_options(o))
          column_sql
        end
      else
        super(o)
      end
    end
  end
end