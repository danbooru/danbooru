class DateTag
  attr_accessor :tag, :start_date, :end_date
  
  def self.new_from_range(start, stop)
    new("#{start.to_formatted_s(:db)}..#{stop.to_formatted_s(:db)}")
  end
  
  def initialize(tag)
    @tag = tag
  end
  
  def is_single_day?
    tag =~ /^\d+-\d+-\d+$/
  end
  
  def is_range?
    !is_single_day
  end
  
  def start_date
    return date if is_single_day?
    extract_ranges
    start_date
  end
  
  def end_date
    return date if is_single_day?
    extract_ranges
    end_date
  end
  
  def previous_week
    DateTag.new_from_range(1.week.ago(start_date), 1.week.ago(end_date))
  end
  
  def next_week
    DateTag.new_from_range(1.week.since(start_date), 1.week.since(end_date))
  end
  
  def previous_month
    DateTag.new_from_range(1.month.ago(start_date), 1.month.ago(end_date))
  end
  
  def next_month
    DateTag.new_from_range(1.month.since(start_date), 1.month.since(end_date))
  end
  
  def date
    Date.parse(tag)
  end
  
  private
    def extract_ranges
      case tag
      when /\A(.+?)\.\.(.+)/
        self.start_date = Date.parse($1)
        self.end_date = Date.parse($2)

      when /\A<(.+)/, /\A<=(.+)/, /\A\.\.(.+)/
        self.start_date = 20.years.ago
        self.end_date = Date.parse($1)

      when /\A>(.+)/, /\A>=(.+)/, /\A(.+)\.\.\Z/
        self.start_date = Date.parse($1)
        self.end_date = Date.today

      else
        self.start_date = Date.today
        self.end_date = Date.today
      end
    end
end
