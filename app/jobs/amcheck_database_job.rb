# frozen_string_literal: true

# A job that runs hourly to check the database for corruption. Spawned by {DanbooruMaintenance}.
# Requires at least PostgreSQL 14.0 to be installed for pg_amcheck to be available.
#
# https://www.postgresql.org/docs/14/app-pgamcheck.html
class AmcheckDatabaseJob < ApplicationJob
  def perform(options: "--verbose --install-missing --heapallindexed --parent-check 2>&1")
    return unless system("pg_amcheck --version > /dev/null")

    connection_url = ApplicationRecord.connection_db_config.url
    output = %x(PGDATABASE="#{connection_url}" pg_amcheck #{options})
    notify(output) unless $?.success?
  end

  def notify(output)
    DanbooruLogger.info(output) unless Rails.env.test?
    Dmail.create_automated(to: User.owner, title: "pg_amcheck failed", body: output)
  end
end
