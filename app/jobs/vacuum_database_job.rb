# frozen_string_literal: true

# A job that runs daily to vacuum the database. Spawned by {DanbooruMaintenance}.
class VacuumDatabaseJob < ApplicationJob
  def perform
    # We can't perform vacuum inside a transaction. This happens during tests.
    return if ApplicationRecord.connection.transaction_open?
    ApplicationRecord.connection.execute("vacuum analyze")
  end
end
