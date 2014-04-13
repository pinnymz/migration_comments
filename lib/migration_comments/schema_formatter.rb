module MigrationComments
  module SchemaFormatter
    def render_comment(comment)
      render_kv_pair(:comment, comment)
    end

    def render_kv_pair(key, value)
      if ::ActiveRecord::VERSION::MAJOR <= 3
        ":#{key} => #{render_value(value)}"
      else
        "#{key}: #{render_value(value)}"
      end
    end

    def render_value(value)
      value.is_a?(String) ? %Q[#{value}].inspect : value
    end
  end
end
