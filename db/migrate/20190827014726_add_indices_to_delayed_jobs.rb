class AddIndicesToDelayedJobs < ActiveRecord::Migration[6.0]
  def up
    # the production db already has this index.
    add_index :delayed_jobs, :locked_at unless index_exists?(:delayed_jobs, :locked_at)
    add_index :delayed_jobs, :locked_by unless index_exists?(:delayed_jobs, :locked_by)
  end

  def down
    remove_index :delayed_jobs, :locked_at if index_exists?(:delayed_jobs, :locked_at)
    remove_index :delayed_jobs, :locked_by if index_exists?(:delayed_jobs, :locked_by)
  end
end
