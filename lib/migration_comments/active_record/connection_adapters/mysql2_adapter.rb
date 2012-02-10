module MigrationComments::ActiveRecord::ConnectionAdapters
  module Mysql2Adapter
    def self.included(base)
      base.class_eval do
        include MigrationComments::ActiveRecord::ConnectionAdapters::MysqlAdapter
      end
    end
  end
end