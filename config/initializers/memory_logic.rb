ActiveSupport::BufferedLogger.class_eval do
  def add_with_memory_info(severity, message = nil, progname = nil, &block)
    str = "\t\e[1;31mMemory usage:\e[0m #{Memorylogic.memory_usage}"
    add_without_memory_info(severity, message + str, progname, &block)
  end

  alias_method_chain :add, :memory_info
end