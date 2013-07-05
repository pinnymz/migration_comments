module MigrationComments::ActiveRecord::ConnectionAdapters
  module SQLite3Adapter
    include AbstractSQLiteAdapter

    def self.included(base)
      base.class_eval do
        alias_method_chain :columns, :migration_comments
        alias_method_chain :copy_table, :migration_comments
        alias_method_chain :change_column, :migration_comments
      end
    end

    def create_table(table_name, options = {})
      td = create_table_definition table_name, options[:temporary], options[:options]
      td.base = self

      unless options[:id] == false
        pk = options.fetch(:primary_key) {
          ActiveRecord::Base.get_primary_key table_name.to_s.singularize
        }

        td.primary_key pk, options.fetch(:id, :primary_key), options
      end
      td.comment options[:comment] if options.has_key?(:comment)

      yield td if block_given?

      if options[:force] && table_exists?(table_name)
        drop_table(table_name, options)
      end

      execute schema_creation.accept td
      td.indexes.each_pair { |c,o| add_index table_name, c, o }
    end

    def columns_with_migration_comments(table_name)
      cols = columns_without_migration_comments(table_name)
      comments = retrieve_column_comments(table_name, *(cols.map(&:name)))
      cols.each do |col|
        col.comment = comments[col.name.to_sym] if comments.has_key?(col.name.to_sym)
      end
      cols
    end

    def copy_table_with_migration_comments(from, to, options = {}) #:nodoc:
      from_primary_key = primary_key(from)
      options[:id] = false
      unless options.has_key?(:comment)
        table_comment = retrieve_table_comment(from)
        options = options.merge(:comment => table_comment) if table_comment
      end
      create_table(to, options) do |definition|
        @definition = definition
        @definition.primary_key(from_primary_key) if from_primary_key.present?
        columns(from).each do |column|
          column_name = options[:rename] ?
              (options[:rename][column.name] ||
                  options[:rename][column.name.to_sym] ||
                  column.name) : column.name
          next if column_name == from_primary_key

          @definition.column(column_name, column.type,
                             :limit => column.limit, :default => column.default,
                             :precision => column.precision, :scale => column.scale,
                             :null => column.null, :comment => column.comment)
        end
        yield @definition if block_given?
      end
      copy_table_indexes(from, to, options[:rename] || {})
      copy_table_contents(from, to,
                          @definition.columns.map {|column| column.name},
                          options[:rename] || {})
    end
  end
end