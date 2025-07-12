module DatabaseTestHelper
  # Run a block of code without the database available. This isn't thread safe, but it's okay as long as parallel tests
  # use processes and not threads.
  def without_database(&block)
    connection = ApplicationRecord.connection_pool.lease_connection

    # XXX Horrible hack to make sure the database connection is lost and can't be reconnected. Simply killing the
    # connection doesn't work because there's no way to stop Rails from automatically reconnecting.
    host = connection.instance_eval { @connection_parameters[:host] }
    connection.instance_eval { @connection_parameters[:host] = "invalid" }
    connection.disconnect!

    yield
  ensure
    connection.instance_eval { @connection_parameters[:host] = host }
    connection.reconnect!
  end
end
