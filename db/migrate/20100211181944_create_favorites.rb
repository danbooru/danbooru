class CreateFavorites < ActiveRecord::Migration[4.2]
  TABLE_COUNT = 100

  def self.up
    # this is a dummy table and should not be used
    create_table "favorites" do |t|
      t.column :user_id, :integer
      t.column :post_id, :integer
    end

    0.upto(TABLE_COUNT - 1) do |i|
      execute <<-EOS
        create table favorites_#{i} (
          check (user_id % 100 = #{i})
        ) inherits (favorites)
      EOS

      add_index "favorites_#{i}", :user_id
      add_index "favorites_#{i}", :post_id
    end

    fragment = []

    1.upto(TABLE_COUNT - 1) do |i|
      fragment << <<-EOS
        elsif (NEW.user_id % 100 = #{i}) then
          insert into favorites_#{i} values (NEW.*);
      EOS
    end

    execute <<-EOS
      create or replace function favorites_insert_trigger()
      returns trigger as $$
      begin
        if (NEW.user_id % 100 = 0) then
          insert into favorites_0 values (NEW.*);
        #{fragment.join("\n")}
        end if;
        return NULL;
      end;
      $$
      language plpgsql
    EOS

    execute <<-EOS
      create trigger insert_favorites_trigger
      before insert on favorites
      for each row execute procedure favorites_insert_trigger()
    EOS
  end

  def self.down
    drop_table "favorites"

    0.upto(TABLE_COUNT - 1) do |i|
      drop_table "favorites_#{i}"
    end
  end
end
