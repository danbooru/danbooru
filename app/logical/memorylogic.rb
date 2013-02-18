module Memorylogic
  class << self
    include ActionView::Helpers::NumberHelper
  end

  def self.memory_usage
    ps = Sys::ProcTable.ps(Process.pid)
    if ps.respond_to?(:rss)
      number_to_human_size(ps.rss.to_i * 1.kilobyte)
    else
      0
    end
  end
end
