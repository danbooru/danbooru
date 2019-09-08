module DurationParser
  def self.parse(string)
    string =~ /(\d+)(s(econds?)?|mi(nutes?)?|h(ours?)?|d(ays?)?|w(eeks?)?|mo(nths?)?|y(ears?)?)?/i

    size = $1.to_i
    unit = $2

    case unit
    when /^s/i
      size.seconds
    when /^mi/i
      size.minutes
    when /^h/i
      size.hours
    when /^d/i
      size.days
    when /^w/i
      size.weeks
    when /^mo/i
      size.months
    when /^y/i
      size.years
    else
      size.seconds
    end
  end
end
