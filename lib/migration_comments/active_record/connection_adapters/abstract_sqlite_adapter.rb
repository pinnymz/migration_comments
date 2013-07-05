module MigrationComments::ActiveRecord::ConnectionAdapters
  module AbstractSQLiteAdapter
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
      result = select_rows(lookup_comment_sql(table_name))
      if result[0][0] =~ /CREATE (?:TEMPORARY )?TABLE #{quote_table_name table_name} [^\(]*\/\*(.*)\*\/ \(/
        $1
      end
    end

    def retrieve_column_comments(table_name, *column_names)
      if column_names.empty?
        return columns(table_name).inject({}) { |m, v| m[v.name.to_sym] = v.comment if v.comment.present?; m }
      end
      result = select_rows(lookup_comment_sql(table_name))
      result[0][0] =~ /^CREATE (?:TEMPORARY )?TABLE "\w*" [^\(]*(?:\/\*.*\*\/ )?\((.*)\)[^\)]*$/
      col_defs = $1
      comment_matches = col_defs.scan(/"([^",]+)"[^,]*\/\*(.+?)\*\//)
      comment_matches.inject({}){|m, row| m[row.first.to_sym] = row.last; m}
    end

    def change_column_with_migration_comments(table_name, column_name, type, options = {}) #:nodoc:
      adapter = self
      alter_table(table_name) do |definition|
        include_default = options_include_default?(options)
        definition[column_name].instance_eval do
          self.type    = type
          self.limit   = options[:limit] if options.include?(:limit)
          self.default = options[:default] if include_default
          self.null    = options[:null] if options.include?(:null)
          self.precision = options[:precision] if options.include?(:precision)
          self.scale   = options[:scale] if options.include?(:scale)
          self.comment = CommentDefinition.new(adapter, table_name, column_name, options[:comment]) if options.include?(:comment)
        end
      end
    end

    def column_for(table_name, column_name)
      columns(table_name).detect{|col| col.name == column_name.to_s}
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
        sql << CommentDefinition.new(self, nil, nil, options[:comment]).to_sql
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