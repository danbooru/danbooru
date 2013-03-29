# yields a stacktrace for each SQL query
# put this file in config/initializers
class QueryTrace < ActiveSupport::LogSubscriber
  include Term::ANSIColor
  attr_accessor :trace_queries

  def sql(event)  #:nodoc:
    return unless QueryTrace.enabled? && logger.debug? && Rails.env.development?
    stack = Rails.backtrace_cleaner.clean(caller)
    first_line = stack.shift
    return unless first_line

    msg = prefix + bold + cyan + "#{first_line}\n" + reset
    msg += cyan + stack.join("\n") + reset
    debug msg
  end

  # :call-seq:
  # Klass.enabled?
  #
  # yields boolean if SQL queries should be logged or not

  def self.enabled?
    defined?(@trace_queries) && @trace_queries
  end

  # :call-seq:
  # Klass.status
  #
  # yields text if QueryTrace has been enabled or not

  def self.status
    QueryTrace.enabled? ? 'enabled' : 'disabled'
  end

  # :call-seq:
  # Klass.enable!
  #
  # turn on SQL query origin logging

  def self.enable!
    @trace_queries = true
  end

  # :call-seq:
  # Klass.disable!
  #
  # turn off SQL query origin logging

  def self.disable!
    @trace_queries = false
  end

  # :call-seq:
  # Klass.toggle!
  #
  # Toggles query tracing yielding a boolean indicating the new state of query
  # origin tracing

  def self.toggle!
    enabled? ? disable! : enable!
    enabled?
  end

protected

  def prefix  #:nodoc:
    bold(magenta('Called from: ')) + reset
  end
end

QueryTrace.attach_to :active_record
QueryTrace.enable! if ENV['QUERY_TRACE']
