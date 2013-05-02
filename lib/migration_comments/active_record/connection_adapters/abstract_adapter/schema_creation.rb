module MigrationComments::ActiveRecord::ConnectionAdapters::AbstractAdapter
  module SchemaCreation
    def self.included(base)
      base.class_eval do
        alias_method_chain :column_options, :migration_comments
      end
    end

    def column_options_with_migration_comments(o)
      column_options = column_options_without_migration_comments(o)
      column_options[:comment] = o.comment.comment_text if o.comment
      column_options
    end
  end
end