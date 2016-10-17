module Danbooru
  module Extensions
    module ActiveRecordApi
      extend ActiveSupport::Concern

      def serializable_hash(options = {})
        options ||= {}
        options[:except] ||= []
        options[:except] += hidden_attributes
        super(options)
      end

      def to_xml(options = {}, &block)
        # to_xml ignores serializable_hash
        options ||= {}
        options[:except] ||= []
        options[:except] += hidden_attributes
        super(options, &block)
      end

    protected
      def hidden_attributes
        [:uploader_ip_addr, :updater_ip_addr, :creator_ip_addr, :ip_addr]
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
