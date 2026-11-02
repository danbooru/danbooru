module DatabaseTestHelper
  # Run a block of code without the database available. This isn't thread safe, but it's okay as long as parallel tests
  # use processes and not threads.
  def without_database(&_block)
    connection = ApplicationRecord.connection_pool.lease_connection

    # XXX Horrible hack to make sure the database connection is lost and can't be reconnected. Simply killing the
    # connection doesn't work because there's no way to stop Rails from automatically reconnecting.
    connection_parameters = connection.instance_eval { @connection_parameters }
    original_parameters = connection_parameters.dup

    connection_parameters.merge!(host: "127.0.0.1", port: 1)
    connection.disconnect!

    yield
  ensure
    connection_parameters.replace(original_parameters)
    connection.reconnect!
  end
end
