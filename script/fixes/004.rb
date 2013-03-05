#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

User.find_each do |user|
  user.update_column(:bcrypt_password_hash, BCrypt::Password.create(user.password_hash))
end
