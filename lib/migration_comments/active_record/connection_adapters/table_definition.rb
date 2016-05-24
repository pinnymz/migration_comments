module MigrationComments::ActiveRecord::ConnectionAdapters
  module TableDefinition
    attr_accessor :table_comment

    def comment(text)
      self.table_comment = CommentDefinition.new(nil, nil, text)
      self
    end

    def column(name, type, options = {})
      super(name, type, options)
      if options.has_key?(:comment)
        col = self[name]
        col.comment = CommentDefinition.new(nil, name, options[:comment])
      end
      self
    end

    def collect_comments(table_name)
      comments = [table_comment] + columns.map(&:comment)
      comments.compact!
      comments.each{|comment| comment.table_name = table_name }
    end
  end
end