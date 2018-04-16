class ChangeTagSubscriptionTagQueryType < ActiveRecord::Migration[4.2]
  def up
    execute "alter table tag_subscriptions alter column tag_query type text"
  end

  def down
    execute "alter table tag_subscriptions alter column tag_query type varchar(255)"
  end
end
