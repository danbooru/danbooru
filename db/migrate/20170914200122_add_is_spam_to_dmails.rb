class AddIsSpamToDmails < ActiveRecord::Migration[4.2]
  def change
  	Dmail.without_timeout do
	    add_column :dmails, :is_spam, :boolean, default: false
	  end
  end
end
