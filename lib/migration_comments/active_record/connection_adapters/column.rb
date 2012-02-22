module MigrationComments::ActiveRecord::ConnectionAdapters
  module Column
    def self.included(base)
      base.class_eval do
        attr_accessor :comment
      end
    end
  end
end