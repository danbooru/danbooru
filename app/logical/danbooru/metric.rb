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
#   metrics = Danbooru::Metric::Set.new({
#     http_requests_total: [:counter, "The total number of HTTP requests received"]
#   }, labels: { env: "production" } )
#
#   # Increment it for every HTTP request.
#   metrics[:http_requests_total][method: "GET"].increment
#   metrics[:http_requests_total][method: "GET"].increment
#   metrics[:http_requests_total][method: "POST"].increment
#
#   # Dump all metrics in Prometheus format (see output below)
#   puts metrics.to_prom
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

    attr_reader :name, :type, :help, :labels, :default_value, :value_hash
    protected attr_writer :labels, :value_hash
    delegate :increment, :set, to: :default_value

    # @param name [Symbol] The name of the metric.
    # @param type [Symbol] The type of the metric (:counter or :gauge).
    # @param help [String] The help text for the metric.
    # @param labels [Hash<Symbol, String>] An optional set of labels for the metric.
    def initialize(name, type: :counter, help: nil, labels: {})
      @name = name.to_sym
      @type = type
      @help = help
      @labels = labels.transform_values(&:to_s).reject { |key, value| value.blank? }
      @value_hash = {}
    end

    # Return the metric value with the given labels. For example, `metrics[:http_requests_total][method: "GET"].increment`
    # increments the `http_requests_total{method="GET"}` counter.
    #
    # A new metric value with be created if one with the given labels doesn't exist.
    #
    # @param labels [Hash<Symbol, String>] The set of labels for the metric.
    # @return [Metric::Value] The metric value with the given labels.
    def [](labels = {})
      value_labels = self.labels.merge(labels)
      value_hash[value_labels] ||= Value.new(self, labels: value_labels)
    end

    # @return [Array<Metric::Value>] The set of values for this metric.
    def values
      value_hash.values
    end

    # Return a new Metric formed by merging the other metrics into a copy of this metric.
    #
    # @param metrics [Array<Metric>] The other metrics to merge into this metric.
    # @return [Metric] The merged metric.
    def merge(*metrics)
      new_metric = dup

      new_metric.value_hash = new_metric.value_hash.merge(*metrics.map(&:value_hash))
      new_metric.labels = new_metric.labels.merge(*metrics.map(&:labels))

      new_metric
    end

    # @return [String] The metric's name, in a human-readable format (e.g. danbooru_posts_total becomes "Posts").
    def pretty_name
      name.to_s.delete_prefix("danbooru_").gsub(/_(bytes|seconds|total)/, "").humanize
    end

    # @return [String] The metric in Prometheus format.
    def to_prom
      str = +""
      str << "# HELP #{name} #{help}\n" if help
      str << "# TYPE #{name} #{type}\n"
      str << (values.sort.map(&:to_prom).join("\n").presence || Value.new(self, labels: labels).to_prom)
      str
    end

    # @return [Danbooru::DataFrame] A DataFrame containing the metric's labels and values.
    def to_dataframe
      data = values.map { |metric_value| { **labels, **metric_value.labels, value: metric_value.value } }
      Danbooru::DataFrame.new(data)
    end

    # The default value for metrics without any labels. For example, `metrics[:http_requests_total].increment`
    # increments the `http_request_total` counter without giving it any labels.
    #
    # @return [Metric::Value] The default label-less value.
    def default_value
      @default_value ||= (value_hash[{}] ||= Value.new(self, labels: labels))
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

  # A Metric::Set represents a collection of related metrics.
  class Metric
    class Set
      # @return metrics [Hash<Symbol, Metric>] The metrics in the set, keyed by metric name.
      attr_reader :metrics

      # @return [Time] The time when the metrics were last updated. Manually updated by the caller.
      attr_accessor :updated_at

      protected attr_writer :metrics

      delegate :[], to: :metrics

      # Create a new metric set, optionally registering a set of metrics at the same time.
      def initialize(...)
        @metrics = {}
        @updated_at = nil
        register(...)
      end

      # Add a new group of metrics to the set.
      #
      # @param definitions [Array<Hash>] The array of metric definitions.
      # @param labels [Hash<Symbol, String>] An optional set of labels to apply to each metric.
      # @return [Metric::Set] The metric set.
      def register(definitions = [], labels: {})
        definitions.each do |definition|
          metrics[definition[:name]] = Metric.new(definition[:name], type: definition[:type], help: definition[:help], labels: labels)
        end

        self
      end

      # Set a group of metrics to the given values.
      #
      # @param values [Hash<Symbol, Float>] A hash of (metric name, value) pairs.
      # @param labels [Hash<Symbol, String>] An optional list of labels to apply to all metrics.
      def set(values, labels = {})
        values.each do |name, value|
          metrics[name][labels].set(value)
        end
      end

      # Return a new Metric::Set formed by merging the other metric sets into a copy of this metric set.
      #
      # @param other_metric_sets [Array<Metric::Set>] The other metric sets to merge into this set.
      # @return [Metric::Set] The merged metric set.
      def merge(*other_metric_sets)
        new_metric_set = dup

        new_metric_set.metrics = metrics.merge(*other_metric_sets.map(&:metrics)) do |name, old_metric, new_metric|
          old_metric.merge(new_metric)
        end

        new_metric_set
      end

      # @return [String] The set of metrics in Prometheus format.
      def to_prom
        metrics.values.map(&:to_prom).join("\n\n")
      end
    end
  end

  # A Metric::Value is a single value belonging to a metric. A metric may have multiple values, one for each unique set of labels.
  class Metric
    class Value
      include ActiveModel::Serializers::JSON
      include ActiveModel::Serializers::Xml
      include Comparable

      attr_reader :name, :labels, :value

      # @param metric [Metric] The Metric this value belongs to.
      # @param value [Integer, Float] The initial value of the metric.
      # @param labels [Hash<Symbol, String>] An optional set of labels for the metric value.
      def initialize(metric, value = 0, labels: {})
        @name = metric.name
        @value = value
        @labels = labels.transform_values(&:to_s).reject { |key, value| value.blank? }
      end

      # @param val [Integer, Float, Boolean, nil] The new value of the metric.
      def set(val)
        case val
        when Integer, Float
          @value = val
        when true
          @value = 1
        when false
          @value = 0
        when nil
          @value = 0
        else
          raise ArgumentError
        end

        self
      end

      # @param val [Integer, Float] The amount to increment the metric by.
      def increment(val = 1)
        @value += val
        self
      end

      # Record time spent executing the given block.
      def increment_duration(&block)
        start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        yield
      ensure
        finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        increment(finish - start)
      end

      # @return [String] The metric labels, in `{name="value"}` format. Quotes, newlines, and backslashes are backslash-escaped.
      def label_string
        @label_string ||=
          if labels.blank?
            ""
          else
            "{" + labels.merge(labels).map do |name, value|
              %{#{name}="#{value.to_s.gsub(/([\\"])/, '\\\\\1').gsub(/\n/, '\\n')}"}
            end.join(", ") + "}"
          end
      end

      # @param other [Metric::Value] The other metric value to compare to.
      # @return [Integer] 1, 0, or -1.
      def <=>(other)
        [name, labels.to_a, value] <=> [other.name, other.labels.to_a, other.value] if other.is_a?(Value)
      end

      # @return [String] The metric in Prometheus format (e.g. `http_requests_total{env="production", method="GET"} 42`).
      def to_prom
        "#{name}#{label_string} #{value}"
      end

      # @return [Hash] The metric value's data (used by #to_json and #to_xml).
      def serializable_hash(*options)
        { labels: labels, value: value }
      end
    end
  end
end
