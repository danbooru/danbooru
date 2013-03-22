#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

ActiveRecord::Base.connection.execute("update wiki_pages set updater_id = (select _.updater_id from wiki_page_versions _ where _.wiki_page_id = wiki_pages.id order by _.updated_at desc limit 1)")
