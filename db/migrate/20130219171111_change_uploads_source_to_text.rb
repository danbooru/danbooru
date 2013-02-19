class ChangeUploadsSourceToText < ActiveRecord::Migration
  def up
    execute "alter table uploads alter column source type text"
  end

  def down
    execute "alter table uploads alter column source type varchar(255)"
  end
end
