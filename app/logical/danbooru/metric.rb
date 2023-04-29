# frozen_string_literal: true

# The Danbooru::Metric class is used for tracking various application metrics and exposing them in Prometheus format at /metrics.
#
# A Metric consists of a name, an optional set of labels, and a value for each unique set of labels.
#
# This is modeled after the Prometheus library, but we implement it ourselves because the Prometheus format is very simple.
#
# @example
#
#   # Define a new metric.
#   Danbooru::Metric.register(:http_requests_total, help: "The total number of HTTP requests received", labels: { env: "production" })
#
#   # Increment it for every HTTP request.
#   Danbooru::Metric[:http_requests_total][method: "GET"].increment
#   Danbooru::Metric[:http_requests_total][method: "GET"].increment
#   Danbooru::Metric[:http_requests_total][method: "POST"].increment
#
#   # Dump all registered metrics in Prometheus format (see output below)
#   puts Danbooru::Metric.to_prom
#
#     # TYPE http_requests_total counter
#     # HELP http_requests_total The total number of HTTP requests received
#     http_requests_total{env="production", method="GET"} 2
#     http_requests_total{env="production", method="POST"} 1
#
# @see https://prometheus.io/docs/concepts/data_model/
# @see https://github.com/OpenObservability/OpenMetrics/blob/main/specification/OpenMetrics.txt
# @see https://github.com/prometheus/client_ruby
# @see app/controllers/metrics_controller.rb
module Danbooru
  class Metric
    include ActiveModel::Serializers::JSON
    include ActiveModel::Serializers::Xml

    mattr_reader :metric_hash, default: {}
    attr_reader :name, :type, :help, :labels, :default_value, :value_hash
    delegate :increment, :set, to: :default_value

    # Register a new metric. See #initialize for details.
    def self.register(name, ...)
      metric_hash[name] = Metric.new(name, ...)
    end

    # @return [Array<Metric>] The set of all registered metrics.
    def self.metrics
      metric_hash.values
    end

    # @param name [Symbol] The name of the metric.
    # @param type [Symbol] The type of the metric (:counter, :gauge, or :histogram).
    # @param help [String] The help text for the metric.
    # @param labels [Hash<Symbol, String>] An optional set of labels for the metric.
    protected def initialize(name, type: :counter, help: nil, labels: {})
      @name = name.to_sym
      @type = type
      @help = help
      @labels = labels
      @value_hash = {}
    end

    # Return the metric with the given name, or raise an exception if it hasn't been registered yet.
    # Example: `Danbooru::Metric[:http_requests_total]`.
    #
    # @param name [Symbol] The name of the metric.
    # @return [Metric] The metric with the given name.
    def self.[](name)
      metric_hash.fetch(name)
    end

    # Return the metric value with the given labels. For example, `Danbooru::Metric[:http_requests_total][method: "GET"].increment`
    # increments the `http_requests_total{method="GET"}` counter.
    #
    # A new metric value with be created if one with the given labels doesn't exist.
    #
    # @param labels [Hash<Symbol, String>] The set of labels for the metric.
    # @return [Value] The Value with the given labels.
    def [](labels = {})
      value_hash[labels] ||= Value.new(self, labels: labels)
    end

    # @return [Array<Value>] The set of values for this metric.
    def values
      value_hash.values
    end

    # @return [String] The metric in Prometheus format.
    def to_prom
      str = +""
      str << "# HELP #{name} #{help}\n" if help
      str << "# TYPE #{name} #{type}\n"
      str << values.map(&:to_prom).join("\n")
      str
    end

    # The default value for metrics without any labels. For example, `Danbooru::Metric[:http_requests_total].increment`
    # increments the `http_request_total` counter without giving it any labels.
    #
    # @return [Value] The default label-less value.
    def default_value
      @default_value ||= (value_hash[{}] ||= Value.new(self))
    end

    # @return [Hash] The metric's data (used by #to_json and #to_xml).
    def serializable_hash(*options)
      {
        name: name,
        type: type,
        help: help,
        labels: labels,
        values: values,
      }
    end
  end

  # A Metric::Value is a single value belonging to a metric. A metric may have multiple values. Each value has a unique set of labels.
  class Metric
    class Value
      include ActiveModel::Serializers::JSON
      include ActiveModel::Serializers::Xml

      attr_reader :metric, :labels, :value

      # @param metric [Metric] The Metric this value belongs to.
      # @param value [Integer, Float] The initial value of the metric.
      # @param labels [Hash<Symbol, String>] An optional set of labels for the metric value.
      def initialize(metric, value = 0, labels: {})
        @metric, @value, @labels = metric, value, labels
      end

      # @param val [Integer, Float] The new value of the metric.
      def set(val)
        @value = val
        self
      end

      # @param val [Integer, Float] The amount to increment the metric by.
      def increment(val = 1)
        @value += val
        self
      end

      # @return [String] The metric labels, in `{name="value"}` format. Quotes, newlines, and backslashes are backslash-escaped.
      def label_string
        return "" if labels.blank?

        "{" + metric.labels.merge(labels).map do |name, value|
          %{#{name}="#{value.to_s.gsub(/([\\"])/, '\\\\\1').gsub(/\n/, '\\n')}"}
        end.join(", ") + "}"
      end

      # @return [String] The metric in Prometheus format (e.g. `http_requests_total{env="production", method="GET"} 42`).
      def to_prom
        "#{metric.name}#{label_string} #{value}"
      end

      # @return [Hash] The metric value's data (used by #to_json and #to_xml).
      def serializable_hash(*options)
        { labels: labels, value: value }
      end
    end
  end
end
