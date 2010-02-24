class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
      t.column :category, :string, :null => false
      t.column :status, :string, :null => false
      t.column :message, :text, :null => false
      t.column :data_as_json, :text, :null => false
      t.column :repeat_count, :integer, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :jobs
  end
end
