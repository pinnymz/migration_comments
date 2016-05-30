module MigrationComments::ActiveRecord::ConnectionAdapters
  module AlterTable
    def add_column(name, type, options)
      super(name, type, options)
      if options.keys.include?(:comment)
        column = @adds.last
        column.comment = CommentDefinition.new(@td, name, options[:comment])
      end
    end
  end
end