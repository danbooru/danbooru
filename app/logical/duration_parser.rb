# frozen_string_literal: true

require 'abbrev'

module DurationParser
  def self.parse(string)
    abbrevs = Abbrev.abbrev(%w[seconds minutes hours days weeks months years])

    raise unless string =~ /(.*?)([a-z]+)\z/i
    size = Float($1)
    unit = abbrevs.fetch($2.downcase)

    case unit
    when "seconds"
      size.seconds
    when "minutes"
      size.minutes
    when "hours"
      size.hours
    when "days"
      size.days
    when "weeks"
      size.weeks
    when "months"
      size * (365.25.days / 12)
    when "years"
      size * (365.25.days)
    else
      raise NotImplementedError
    end
  rescue
    raise ArgumentError, "'#{string}' is not a valid duration"
  end
end
