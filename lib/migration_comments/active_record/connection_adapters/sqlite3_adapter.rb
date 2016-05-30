module MigrationComments::ActiveRecord::ConnectionAdapters
  module SQLite3Adapter

    def comments_supported?
      true
    end

    def inline_comments?
      true
    end

    def set_table_comment(table_name, comment_text)
      alter_table(table_name, :comment => comment_text)
    end

    def set_column_comment(table_name, column_name, comment_text)
      sql_type = primary_key(table_name) == column_name.to_s ?
          :primary_key :
          column_for(table_name, column_name).sql_type
      change_column table_name, column_name, sql_type, :comment => comment_text
    end

    def retrieve_table_comment(table_name)
      result = select_value(lookup_comment_sql(table_name))
      $1 if result =~ /CREATE (?:TEMPORARY )?TABLE #{quote_table_name table_name} [^\(]*\/\*(.*)\*\/ \(/
    end

    def retrieve_column_comments(table_name, *column_names)
      if column_names.empty?
        return columns(table_name).inject({}) { |m, v| m[v.name.to_sym] = v.comment if v.comment.present?; m }
      end
      result = select_value(lookup_comment_sql(table_name))
      result =~ /^CREATE (?:TEMPORARY )?TABLE "\w*" [^\(]*(?:\/\*.*\*\/ )?\((.*)\)[^\)]*$/
      col_defs = $1
      comment_matches = col_defs.scan(/"([^",]+)"[^,]*\/\*(.+?)\*\//)
      Hash[comment_matches.map{|col_name, comment| [col_name.to_sym, comment.presence] }]
    end

    def create_table(table_name, options = {})
      super(table_name, options) do |td|
        td.comment = options[:comment] if options.has_key?(:comment)
        yield td if block_given?
      end
    end

    def columns(table_name)
      cols = super(table_name)
      comments = retrieve_column_comments(table_name, *(cols.map(&:name)))
      cols.each do |col|
        col.comment = comments[col.name.to_sym] if comments.has_key?(col.name.to_sym)
      end
      cols
    end

    def copy_table(from, to, options = {}) #:nodoc:
      unless options.has_key?(:comment)
        table_comment = retrieve_table_comment(from)
        options.merge!(comment: table_comment) if table_comment
      end
      super(from, to, options) do |definition|
        retrieve_column_comments(from).each do |col_name, comment|
          definition[col_name].comment = CommentDefinition.new(from, col_name, comment)
        end
        yield definition if block_given?
      end
    end

    def change_column(table_name, column_name, type, options = {}) #:nodoc:
      super(table_name, column_name, type, options)
      if options.has_key?(:comment)
        alter_table(table_name) do |definition|
          definition[column_name].comment = CommentDefinition.new(table_name, column_name, options[:comment])
        end
      end
    end

    def comment_sql(comment_definition)
      if comment_definition.nil? || comment_definition.comment_text.blank?
        ""
      else
        " /*#{escaped_comment(comment_definition.comment_text)}*/"
      end

    end

    def add_column_options!(sql, options)
      super(sql, options)
      if options.keys.include?(:comment)
        sql << comment_sql(CommentDefinition.new(nil, nil, options[:comment]))
      end
    end

    private
    def escaped_comment(comment)
      comment.gsub(/\*\//, "*-/")
    end

    def lookup_comment_sql(table_name)
      "select sql from (select * from sqlite_master where type='table' union select * from sqlite_temp_master where type='table') where tbl_name = '#{table_name}'"
    end
  end
end