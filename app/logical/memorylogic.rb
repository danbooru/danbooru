module Memorylogic
  class << self
    include ActionView::Helpers::NumberHelper
  end

  def self.memory_usage
    number_to_human_size(`ps -o rss= -p #{Process.pid}`.to_i * 1.kilobyte)
  end
end
