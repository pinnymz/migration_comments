module MigrationComments::ActiveRecord
  module SchemaDumper
    def self.included(base)
      base.class_eval do
        alias_method_chain :table, :migration_comments
      end
    end

    def table_with_migration_comments(table, stream)
      tbl_stream = StringIO.new
      table_without_migration_comments(table, tbl_stream)
      tbl_stream.rewind
      commented_stream = append_comments(table, tbl_stream)
      tbl_stream.close
      stream.print commented_stream.read
    end

    def append_comments(table, stream)
      table_name = table.inspect.gsub('"', '')
      table_comment = @connection.retrieve_table_comment(table_name)
      column_comments = @connection.retrieve_column_comments(table_name)
      comment_stream = StringIO.new
      lines = []
      table_line = 0
      col_names = {}
      while (line = stream.gets)
        content = line.chomp
        if content =~ /create_table\s/
          table_line = lines.size
        elsif content =~ /t\.\w+\s+"(\w+)"/
          col_names[lines.size] = $1.to_sym
        end
        lines << content
      end
      len = col_names.keys.map{|index| lines[index]}.map(&:length).max + 2 unless col_names.empty?
      lines.each_with_index do |line, index|
        unless line[0] == '#'
          if table_line == index && table_comment.present?
            block_init = " do |t|"
            line.chomp!(block_init) << ", " << render_comment(table_comment) << block_init
          elsif col_names[index]
            comment = column_comments[col_names[index]]
            line << ',' << ' ' * (len - line.length) << render_comment(comment) unless comment.blank?
          end
        end
        comment_stream.puts line
      end
      comment_stream.rewind
      comment_stream
    end

    def render_comment(comment)
      ":comment => \"#{comment}\""
    end
  end
end