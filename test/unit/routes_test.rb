require "test_helper"

class RoutesTest < ActiveSupport::TestCase
  context "The routes" do
    should "only point to controller actions that exist" do
      missing_routes = Rails.application.routes.routes.filter_map do |route|
        controller = route.defaults[:controller]
        action = route.defaults[:action]
        next if controller.nil? || action.nil? || controller.start_with?("rails/", "active_storage/", "action_mailbox/")

        klass = "#{controller.camelize}Controller".safe_constantize
        next "#{route.verb} #{route.path.spec} => #{controller}##{action} (controller doesn't exist)" if klass.nil?

        # Check only the controller's own view folder. Shared templates like app/views/application/index.sitemap.erb
        # would otherwise make missing `index` actions look like they exist.
        next if klass.action_methods.include?(action) || klass.new.lookup_context.exists?(action, [klass.controller_path])

        "#{route.verb} #{route.path.spec} => #{controller}##{action}"
      end

      assert_equal([], missing_routes, "These routes point to controller actions that don't exist. Use `only:` or `except:` in config/routes.rb to remove them.")
    end

    should "have a route for every controller action" do
      Rails.application.eager_load!
      routed_actions = Rails.application.routes.routes.to_set { |route| [route.defaults[:controller], route.defaults[:action]] }

      unrouted_actions = ApplicationController.descendants.reject(&:abstract?).flat_map do |klass|
        klass.action_methods.reject { |action| routed_actions.include?([klass.controller_path, action]) }.map { |action| "#{klass.controller_path}##{action}" }
      end

      assert_equal([], unrouted_actions.sort, "These public controller methods don't have a route. Make them private if they aren't actions, or remove them if they're unused.")
    end
  end
end
