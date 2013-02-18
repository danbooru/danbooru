module Memorylogic
  class << self
    include ActionView::Helpers::NumberHelper
  end

  def self.memory_usage
    ps = Sys::ProcTable.ps(Process.pid)
    if ps.respond_to?(:pctmem)
      ps.pctmem
    else
      0
    end
  end
end
