module MigrationComments::ActiveRecord::ConnectionAdapters
  module TableDefinition

    attr_accessor :table_comment
    def self.included(base)
      base.class_eval do
        alias_method_chain :column, :migration_comments
      end
    end

    def comment(text)
      @table_comment = CommentDefinition.new(@base, nil, nil, text)
      self
    end

    def column_with_migration_comments(name, type, options = {})
      column_without_migration_comments(name, type, options)
      if options.has_key?(:comment)
        col = self[name]
        col.comment = CommentDefinition.new(@base, nil, name, options[:comment])
      end
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