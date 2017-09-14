class AddIsSpamToDmails < ActiveRecord::Migration
  def change
  	Dmail.without_timeout do
	    add_column :dmails, :is_spam, :boolean, default: false
	  end
  end
end
