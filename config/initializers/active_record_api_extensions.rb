module Danbooru
  module Extensions
    module ActiveRecordApi
      extend ActiveSupport::Concern

      def as_json(options = {})
        options ||= {}
        options[:except] ||= []
        options[:except] += hidden_attributes

        options[:methods] ||= []
        options[:methods] += method_attributes

        super(options)
      end

      def to_xml(options = {}, &block)
        options ||= {}

        options[:except] ||= []
        options[:except] += hidden_attributes

        options[:methods] ||= []
        options[:methods] += method_attributes

        super(options, &block)
      end

      def serializable_hash(*args)
        hash = super(*args)
        hash.transform_keys { |key| key.delete("?") }
      end

    protected
      def hidden_attributes
        [:uploader_ip_addr, :updater_ip_addr, :creator_ip_addr, :ip_addr]
      end

      def method_attributes
        []
      end
    end
  end
end

class Delayed::Job
  def hidden_attributes
    [:handler]
  end
end

class ActiveRecord::Base
  include Danbooru::Extensions::ActiveRecordApi
end
