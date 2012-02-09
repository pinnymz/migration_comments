module MigrationComments
  module AnnotateModels
    def self.included(base)
      base.class_eval do
        class << self
          include ClassMethods
          alias_method_chain :get_schema_info, :migration_comments
        end
      end
    end

    module ClassMethods
      def get_schema_info_with_migration_comments(*args)
        info = get_schema_info_without_migration_comments(*args)
        klass = args[0]
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
            line << " # #{table_comment}" if table_comment
          elsif line =~ column_regex
            comment = column_comments[$1.to_sym]
            line << " " * (len - line.length) << " # #{comment}" if comment
          end
        end
        lines.join($/) + $/
      end
    end
  end
end