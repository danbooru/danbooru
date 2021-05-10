#!/usr/bin/env ruby

require_relative "../../config/environment"

EmailAddress.transaction do
  EmailAddress.valid(false).destroy_all
end
