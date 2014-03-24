#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

Iqdb::Server.import(Danbooru.config.iqdb_file)
