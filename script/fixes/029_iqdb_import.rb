#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

Iqdb::Server.import("/var/www/danbooru2/shared/iqdb.db")
