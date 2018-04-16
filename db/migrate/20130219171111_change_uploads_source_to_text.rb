class ChangeUploadsSourceToText < ActiveRecord::Migration[4.2]
  def up
    execute "alter table uploads alter column source type text"
  end

  def down
    execute "alter table uploads alter column source type varchar(255)"
  end
end
