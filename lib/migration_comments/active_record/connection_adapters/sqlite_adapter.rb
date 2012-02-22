module MigrationComments::ActiveRecord::ConnectionAdapters
  module SQLiteAdapter
    def self.included(base)
      base.class_eval do
        alias_method_chain :columns, :migration_comments
        alias_method_chain :copy_table, :migration_comments
        alias_method_chain :change_column, :migration_comments
      end
    end

    def add_table_comment(table_name, comment_text)
      alter_table(table_name, :comment => comment_text)
    end

    def add_column_comment(table_name, column_name, comment_text)
      column = column_for(table_name, column_name)
      change_column table_name, column_name, column.sql_type, :comment => comment_text
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
      comment_matches = col_defs.scan(/\"([^",]+)\"[^,]*\/\*(.+?)\*\//)
      comment_matches.inject({}){|m, row| m[row.first.to_sym] = row.last; m}
    end

    def create_table(table_name, options = {})
      td = table_definition
      td.primary_key(options[:primary_key] || ActiveRecord::Base.get_primary_key(table_name.to_s.singularize)) unless options[:id] == false
      td.comment options[:comment] if options.has_key?(:comment)

      yield td if block_given?

      if options[:force] && table_exists?(table_name)
        drop_table(table_name)
      end

      create_sql = "CREATE#{' TEMPORARY' if options[:temporary]} TABLE "
      create_sql << "#{quote_table_name(table_name)}#{td.table_comment} ("
      create_sql << td.columns.map do |column|
        column.to_sql + column.comment.to_sql
      end * ", "
      create_sql << ") #{options[:options]}"
      execute create_sql
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

    def columns_with_migration_comments(table_name, name = nil)
      cols = columns_without_migration_comments(table_name, name)
      comments = retrieve_column_comments(table_name, *(cols.map(&:name)))
      cols.each do |col|
        col.comment = comments[col.name.to_sym] if comments.has_key?(col.name.to_sym)
      end
      cols
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

    def copy_table_with_migration_comments(from, to, options = {}) #:nodoc:
      options = options.merge(:id => (!columns(from).detect{|c| c.name == 'id'}.nil? && 'id' == primary_key(from).to_s))
      unless options.has_key?(:comment)
        table_comment = retrieve_table_comment(from)
        options = options.merge(:comment => table_comment) if table_comment
      end
      create_table(to, options) do |definition|
        @definition = definition
        columns(from).each do |column|
          column_name = options[:rename] ?
            (options[:rename][column.name] ||
             options[:rename][column.name.to_sym] ||
             column.name) : column.name
          @definition.column(column_name, column.type,
            :limit => column.limit, :default => column.default,
            :precision => column.precision, :scale => column.scale,
            :null => column.null, :comment => column.comment)
        end
        @definition.primary_key(primary_key(from)) if primary_key(from)
        yield @definition if block_given?
      end

      copy_table_indexes(from, to, options[:rename] || {})
      copy_table_contents(from, to,
        @definition.columns.map {|column| column.name},
        options[:rename] || {})
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
      "select sql from (select * from sqlite_master union select * from sqlite_temp_master) where tbl_name = '#{table_name}'"
    end
  end
end