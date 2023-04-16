# frozen_string_literal: true

# This module contains helper functions used in database migrations.
module MigrationHelpers
  # Add a NOT NULL constraint without locking the table against writes while the constraint is validated.
  #
  # @see https://dba.stackexchange.com/questions/267947/how-can-i-set-a-column-to-not-null-without-locking-the-table-during-a-table-scan
  # @see https://gitlab.com/gitlab-org/gitlab/-/blob/c2d4b86b35b50a45d2bac5b3c053b5dc77b1fa44/lib/gitlab/database/migrations/constraints_helpers.rb#L213
  def add_not_null_constraint(table, column)
    constraint_name = "#{table}_#{column}_check_not_null"

    reversible do |dir|
      dir.up do
        execute("ALTER TABLE #{table} DROP CONSTRAINT IF EXISTS #{constraint_name};")
        add_check_constraint(table, "#{column} IS NOT NULL", name: constraint_name, validate: false)
        execute("ALTER TABLE #{table} VALIDATE CONSTRAINT #{constraint_name};")
        change_column_null(table, column, false)
        remove_check_constraint(table, name: constraint_name)
      end

      dir.down do
        execute("ALTER TABLE #{table} DROP CONSTRAINT IF EXISTS #{constraint_name};")
        change_column_null(table, column, true)
      end
    end
  end
end
