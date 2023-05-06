module DatabaseTestHelper
  # Run a block of code without the database available. This isn't thread safe, but it's okay as long as parallel tests
  # use processes and not threads.
  def without_database
    ApplicationRecord.connection_pool.automatic_reconnect = false
    ApplicationRecord.connection_pool.disconnect!

    yield
  ensure
    ApplicationRecord.connection_pool.automatic_reconnect = true
    ApplicationRecord.connection_pool.connection.reconnect!
  end
end
