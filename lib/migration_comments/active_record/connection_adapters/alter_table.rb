module MigrationComments::ActiveRecord::ConnectionAdapters
  module AlterTable
    def add_column(name, type, options)
      super(name, type, options)
      if options.keys.include?(:comment)
        added_entity = @adds.last
        column = added_entity.respond_to?(:column) ? added_entity.column : added_entity
        column.comment = CommentDefinition.new(@td, name, options[:comment])
      end
    end
  end
end