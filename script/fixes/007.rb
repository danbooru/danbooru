#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")
ActiveRecord::Base.connection.execute("update comments set updater_id = creator_id where updater_id is null")
ActiveRecord::Base.connection.execute("update forum_posts set updater_id = creator_id where updater_id is null")
ActiveRecord::Base.connection.execute("update tags set post_count = 0 where post_count < 0")
