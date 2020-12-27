#!/usr/bin/env ruby

require_relative "../../config/environment"

EmailAddress.transaction do
  EmailAddress.where("address !~ ? AND address !~ ?", "@", "\\.").count
end
