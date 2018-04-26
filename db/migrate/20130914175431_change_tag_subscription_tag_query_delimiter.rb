class ChangeTagSubscriptionTagQueryDelimiter < ActiveRecord::Migration[4.2]
  def change
    execute "set statement_timeout = 0"
    TagSubscription.find_each do |tag_subscription|
      tag_subscription.update_column(:tag_query, tag_subscription.tag_query.scan(/\S+/).join("\n"))
    end
  end
end
