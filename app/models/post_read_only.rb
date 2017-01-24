class PostReadOnly < Post
  establish_connection (ENV["RO_DATABASE_URL"] || "ro_#{Rails.env}".to_sym)
  attr_readonly *column_names

  def with_timeout(n, default_value = nil)
    connection.execute("SET STATEMENT_TIMEOUT = #{n}") unless Rails.env == "test"
    yield
  rescue ::ActiveRecord::StatementInvalid => x
    return default_value
  ensure
    connection.execute("SET STATEMENT_TIMEOUT = 0") unless Rails.env == "test"
  end
end
