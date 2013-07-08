module MigrationComments::ActiveRecord::ConnectionAdapters
  module MysqlAdapter
    def self.included(base)
      base.class_eval do
        alias_method_chain :create_table, :migration_comments
        alias_method_chain :change_column, :migration_comments
      end
    end

    def comments_supported?
      true
    end

    def set_table_comment(table_name, comment_text)
      execute "ALTER TABLE #{quote_table_name table_name} COMMENT #{escaped_comment(comment_text)}"
    end

    def set_column_comment(table_name, column_name, comment_text)
      pk_info = pk_and_sequence_for(table_name)
      if pk_info && pk_info.first == column_name.to_s             # change_column broken for :primary_key
        primary_col_def = native_database_types[:primary_key].sub(/ PRIMARY KEY/i, '')
        execute "ALTER TABLE #{quote_table_name table_name} CHANGE #{quote_column_name column_name} #{quote_column_name column_name} #{primary_col_def} COMMENT #{escaped_comment(comment_text)};"
      else
        column = column_for(table_name, column_name)
        change_column table_name, column_name, column.sql_type, :comment => comment_text
      end
    end

    def retrieve_table_comment(table_name)
      result = select_rows(table_comment_sql(table_name))
      result[0].nil? || result[0][0].blank? ? nil : result[0][0]
    end

    def retrieve_column_comments(table_name, *column_names)
      result = select_rows(column_comment_sql(table_name, *column_names))
      return {} if result.nil?
      result.inject({}){|m, row| m[row[0].to_sym] = (row[1].blank? ? nil : row[1]); m}
    end

    def create_table_with_migration_comments(table_name, options={})
      local_table_definition = nil
      create_table_without_migration_comments(table_name, options) do |td|
        local_table_definition = td
        local_table_definition.base = self
        local_table_definition.comment options[:comment] if options.has_key?(:comment)
        yield td if block_given?
      end
      comments = local_table_definition.collect_comments(table_name)
      comments.each do |comment_definition|
        execute_comment comment_definition
      end
    end

    def change_column_with_migration_comments(table_name, column_name, type, options={})
      unless options.keys.include?(:comment)
        options.merge!(:comment => retrieve_column_comment(table_name, column_name))
      end
      change_column_without_migration_comments(table_name, column_name, type, options)
    end

    def add_column_options!(sql, options)
      super(sql, options)
      if options.keys.include?(:comment)
        sql << " COMMENT #{escaped_comment(options[:comment])}"
      end
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
      col_matcher_sql = column_names.empty? ? "" : " AND column_name IN (#{column_names.map{|c_name| "'#{c_name}'"}.join(',')})"
      <<SQL
SELECT column_name, column_comment FROM INFORMATION_SCHEMA.COLUMNS
  WHERE table_schema = '#{database_name}'
  AND table_name = '#{table_name}' #{col_matcher_sql}
SQL
    end

    def database_name
      @database_name ||= select_rows("SELECT DATABASE()")[0][0]
    end

  end
end