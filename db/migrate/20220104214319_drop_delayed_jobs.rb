class DropDelayedJobs < ActiveRecord::Migration[6.1]
  def up
    drop_table :delayed_jobs
  end

  def down
    create_table :delayed_jobs do |t|
      t.integer  :priority, default: 0
      t.integer  :attempts, default: 0
      t.text     :handler
      t.text     :last_error
      t.datetime :run_at
      t.datetime :locked_at
      t.datetime :failed_at
      t.string   :locked_by
      t.timestamps null: false
      t.string   :queue
    end

    add_index :delayed_jobs, :run_at
    add_index :delayed_jobs, :locked_at
    add_index :delayed_jobs, :locked_by
  end
end
