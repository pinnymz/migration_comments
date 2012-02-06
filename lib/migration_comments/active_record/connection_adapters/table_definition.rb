module MigrationComments::ActiveRecord::ConnectionAdapters
  module TableDefinition
    attr_accessor :table_comment
    def self.included(base)
      base.class_eval do
        alias_method_chain :column, :migration_comments
      end
    end

    def comment(text)
      @table_comment = CommentDefinition.new(nil, nil, text)
      self
    end

    def column_with_migration_comments(name, type, options = {})
      column_without_migration_comments(name, type, options)
      col = self[name]
      col.comment = options[:comment]
      self
    end

    def collect_comments(table_name)
      comments = []
      comments << @table_comment << @columns.map(&:comment)
      comments.flatten!.compact!
      comments.each{|comment| comment.table = table_name}
    end
  end
end