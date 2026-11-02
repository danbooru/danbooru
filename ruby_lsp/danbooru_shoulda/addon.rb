# frozen_string_literal: true

# Custom Ruby LSP add-on that adds "Run" code lenses above `context` and `should` test blocks. This is necessary because
# Ruby LSP only supports RSpec-style `describe` and `it` blocks, not `context` and `should`.
#
# This should be removed if and when we migrate to RSpec-style tests.

require "shellwords"
require "ruby_lsp/addon"
require "ruby_lsp/internal"

RubyLsp::Addon.depend_on_ruby_lsp!(">= 0.26.0")

module RubyLsp
  module DanbooruShoulda
    class Addon < ::RubyLsp::Addon
      def activate(global_state, _outgoing_queue)
        @global_state = global_state
      end

      def deactivate
      end

      def name
        "Danbooru Shoulda"
      end

      def version
        "0.1.0"
      end

      def create_discover_tests_listener(response_builder, dispatcher, uri)
        TestStyle.new(response_builder, @global_state, dispatcher, uri) if @global_state
      end

      # ActiveSupport's `delegate` isn't available inside the Ruby LSP process.
      def resolve_test_commands(items) # rubocop:disable Rails/Delegate
        TestStyle.resolve_test_commands(items)
      end
    end

    class TestStyle < Listeners::TestDiscovery
      BASE_COMMAND = "bundle exec ruby -r#{Listeners::TestStyle::MINITEST_REPORTER_PATH} bin/rails test"

      # `root` holds the items of a class until they're attached to the class item at the end of the class.
      ClassScope = Struct.new(:name, :root)

      # Builds one command per selected `context` or `should`. Classes, files and directories are handled by the Rails add-on.
      def self.resolve_test_commands(items)
        items.filter_map do |item|
          tags = item[:tags]
          path = URI(item[:uri]).full_path
          next unless path && tags.include?("framework:shoulda")

          class_name, method_name = item[:id].split("#", 2)
          suffix = tags.include?("test_group") ? "" : "$"
          pattern = "/^#{Regexp.escape(class_name)}##{Regexp.escape(method_name)}#{suffix}/"

          "#{BASE_COMMAND} #{Shellwords.escape(path)} --name #{Shellwords.escape(pattern)}"
        end
      end

      def initialize(response_builder, global_state, dispatcher, uri)
        super(response_builder, global_state, uri)
        @classes = []
        @contexts = []
        register_events(dispatcher, :on_class_node_enter, :on_call_node_enter, :on_call_node_leave)
      end

      def on_class_node_enter(node)
        with_test_ancestor_tracking(node) do |name, ancestors|
          @classes << (ancestors.include?("Minitest::Test") ? ClassScope.new(name, ResponseBuilders::TestCollection.new) : nil)
        end
      end

      # Attach our items to the class item created by the Rails add-on.
      def on_class_node_leave(node)
        scope = @classes.pop
        class_item = scope && @response_builder[scope.name]
        scope.root.response.each { |item| class_item.add(item) } if class_item
        super
      end

      def on_call_node_enter(node)
        kind, label = shoulda_call(node)
        return unless kind

        scope = @classes.last
        context_names = @contexts.last || []

        if kind == :context
          names = [*context_names, label]
          scope.root.add(build_item(scope.name, "test_: #{names.join(" ")} ", label, node))
          @contexts << names
        else
          # A `should` outside any context is named after the class.
          names = context_names.empty? ? [scope.name.delete_suffix("Test")] : context_names
          scope.root.add(build_item(scope.name, "test_: #{names.join(" ")} should #{label}. ", label, node))
        end
      end

      def on_call_node_leave(node)
        kind, = shoulda_call(node)
        @contexts.pop if kind == :context
      end

      private

      # Returns [:context | :should, "label"] for `context "..." do` and `should "..." do` calls inside test classes.
      def shoulda_call(node)
        return unless @classes.last && node.block && %i[context should].include?(node.name)

        label = node.arguments&.arguments&.first
        [node.name, label.unescaped] if label.is_a?(Prism::StringNode)
      end

      def build_item(class_name, method_name, label, node)
        item = Requests::Support::TestItem.new("#{class_name}##{method_name}", label, @uri, range_from_node(node), framework: :shoulda)
        @response_builder.add_code_lens(item)
        item
      end
    end
  end
end
