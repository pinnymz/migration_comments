module MigrationComments::ActiveRecord::ConnectionAdapters
  module TableDefinition
    attr_accessor :comment

    def comment=(text)
      @comment = text.respond_to?(:comment_text) ? text : CommentDefinition.new(nil, nil, text)
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
      comments = [comment] + columns.map(&:comment)
      comments.compact!
      comments.each{|comment| comment.table_name = table_name }
    end
  end
end