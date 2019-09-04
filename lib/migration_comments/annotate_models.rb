module MigrationComments
  module AnnotateModels
    def self.prepended(base)
      class << base
        prepend ClassMethods
      end
    end

    module ClassMethods
      def get_schema_info(*args)
        klass = args[0]
        klass.reset_column_information
        info = super(*args)
        commented_info(klass, info)
      end

      def commented_info(klass, info)
        table_name = klass.table_name
        adapter = klass.connection
        table_comment = adapter.retrieve_table_comment(table_name)
        column_comments = adapter.retrieve_column_comments(table_name)
        lines = []
        info.each_line{|l| lines << l.chomp}
        column_regex = /^#\s+(\w+)\s+:\w+/
        len = lines.select{|l| l =~ column_regex}.map{|l| l.length}.max
        lines.each do |line|
          if line =~ /# Table name: |# table \+\w+\+ /
            table_comment_lines = table_comment.chomp.split($/)
            space_size = line.length - 1
            first_comment = table_comment_lines.shift
            line << " # #{first_comment}" if table_comment

            table_comment_lines.each do |comment_line|
              line << $/ << "#" << " " * space_size << " # #{comment_line}"
            end
          elsif line =~ column_regex
            comment = column_comments[$1.to_sym]
            next unless comment

            comment_lines = comment.chomp.split($/)
            first_comment = comment_lines.shift
            line << " " * (len - line.length) << " # #{first_comment}"

            comment_lines.each do |comment_line|
              line << $/ << "#" << " " * (len - 1) << " # #{comment_line}"
            end
          end
        end
        lines.join($/) + $/
      end
    end
  end
end
