#!/usr/bin/env ruby

require_relative "../../config/environment"

EmailAddress.transaction do
  User.where.not(email: nil).find_each.with_index do |user, n|
    email = EmailAddress.new(user: user, address: user.email, is_verified: true)
    email.normalized_address = email.normalized_address.to_s
    email.save(validate: false)
    puts "n=#{n} id=#{user.id} name=#{user.name} email=#{user.email} normalized_address=#{email.normalized_address}"
  end
end
