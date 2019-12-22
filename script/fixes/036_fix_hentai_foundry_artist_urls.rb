#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

CurrentUser.user = User.admins.first
CurrentUser.ip_addr = "127.0.0.1"

ArtistUrl.where("normalized_url like 'http://pictures.hentai-foundry.com//%'").update_all("normalized_url = replace(normalized_url, 'http://pictures.hentai-foundry.com//', 'http://pictures.hentai-foundry.com/')")
