module MigrationComments::ActiveRecord
  module SchemaDumper
    include MigrationComments::SchemaFormatter

    def table(table, stream)
      return super if ::ActiveRecord::VERSION::MAJOR >= 5 && @connection.class.name !~ /SQLite/
      tbl_stream = StringIO.new
      super(table, tbl_stream)
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
      error = false
      while (stream_line = stream.gets)
        content = stream_line.chomp
        if content =~ /^# Could not dump table "#{table_name}"/
          error = true
        elsif content =~ /create_table\s/
          table_line = lines.size
        elsif content =~ /t\.\w+\s+"(\w+)"/
          col_names[lines.size] = $1.to_sym
        end
        lines << content
      end
      len = col_names.keys.map{|index| lines[index]}.map(&:length).max + 2 unless col_names.empty?
      lines.each_with_index do |line, index|
        if error
          # do nothing
        elsif table_line == index && table_comment.present?
          block_init = " do |t|"
          line.chomp!(block_init) << ", " << render_comment(table_comment) << block_init
        elsif col_names[index] && ::ActiveRecord::VERSION::MAJOR < 5
          comment = column_comments[col_names[index]]
          line << ',' << ' ' * (len - line.length) << render_comment(comment) unless comment.blank?
        end
        comment_stream.puts line
      end
      comment_stream.rewind
      comment_stream
    end
  end
end