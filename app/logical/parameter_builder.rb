# frozen_string_literal: true

# This class parses the `only=` query parameter for API responses.
class ParameterBuilder
  extend Memoist

  class Error < StandardError; end

  MAX_LENGTH = 1_000 # The maximum length of the `only=` string.
  MAX_DEPTH = 8 # The maximum number of nested fields in the `only=` string.

  attr_reader :only_string, :object

  def initialize(only_string, object)
    @only_string = only_string.to_s
    @object = object
  end

  def serial_parameters
    build_only_hash(only_array, object)
  end

  def includes_parameters
    build_includes_array(only_array, object)
  end

  private

  def build_only_hash(items, object, seen_objects = [])
    return {} if object.nil?

    is_root = seen_objects.empty?
    hash = { only: [], include: [], methods: [] }
    available_includes = object.available_includes
    attributes, methods = object.api_attributes.partition { |attr| object.has_attribute?(attr) }
    methods -= available_includes
    seen_objects << object.class.name

    items.each do |key, nested|
      item_sym = key.to_sym
      seen = inclusion_seen?(item_sym.to_s, object.class, seen_objects)

      if nested.present? && available_includes.include?(item_sym) && (!seen || is_root)
        child = object.public_send(item_sym)
        next if child.nil?

        child_records = child.is_a?(ActiveRecord::Relation) ? child.to_a : [child]
        merged = child_records.map { |record| build_only_hash(nested, record, seen_objects.dup) }
        merged = merged.reduce { |memo, entry| memo.deep_merge(entry) { |_key, left, right| left | right } }
        hash[:include] << { item_sym => merged }
      elsif attributes.include?(item_sym)
        hash[:only] << item_sym
      elsif methods.include?(item_sym)
        hash[:methods] << item_sym
        hash[:only] << item_sym
      elsif available_includes.include?(item_sym) && (!seen || is_root)
        hash[:include] << item_sym
      end
    end

    hash.delete(:include) if hash[:include].empty?
    hash.delete(:methods) if hash[:methods].empty?
    hash
  end

  def build_includes_array(items, model_name, seen_objects = [])
    is_root = seen_objects.empty?
    include_array = []
    model = model_name.is_a?(String) ? model_name.constantize : model_name
    available_includes = model.available_includes
    seen_objects << model_name.to_s

    items.each do |key, nested|
      item_sym = key.to_sym
      seen = inclusion_seen?(item_sym.to_s, model, seen_objects)

      if nested.present? && available_includes.include?(item_sym) && (!seen || is_root)
        model.associated_models(item_sym.to_s).each do |child_model|
          child_items = build_includes_array(nested, child_model, seen_objects.dup)
          include_array << (child_items.empty? ? item_sym : { item_sym => child_items })
        end
      elsif available_includes.include?(item_sym) && (!seen || is_root)
        include_array << item_sym
      end
    end

    include_array
  end

  def inclusion_seen?(inclusion, class_object, seen_objects)
    reflection = class_object.reflections[inclusion]
    return false if reflection.nil?

    inclusion_class = reflection.class_name
    max_seen = class_object.multiple_includes.include?(inclusion.to_sym) ? 1 : 0
    seen_objects.count(inclusion_class) > max_seen
  end

  # @return [Hash<Symbol, Hash>] The only= string parsed into nested hashes.
  # @example `id,comments[body,creator[name]]` becomes: { id: {}, comments: { body: {}, creator: { name: {} } } }
  memoize def only_array
    raise Error, "param too long (max #{MAX_LENGTH} characters)" if only_string.size > MAX_LENGTH

    parser = StringParser.new(only_string)
    current = {}
    stack = [current]

    until parser.eos?
      name = parser.expect(/[a-zA-Z_]+/).to_sym
      current[name] = {}

      if parser.accept("[")
        stack << current[name]
        current = stack.last
        raise Error, "param is nested too deeply (max #{MAX_DEPTH} levels)" if stack.size > MAX_DEPTH + 1
      else
        while parser.accept("]")
          stack.pop
          raise Error, "unbalanced brackets" if stack.empty?
          current = stack.last
        end
      end

      parser.skip(/[[:space:],]*/)
    end

    raise Error, "unbalanced brackets" if stack.size != 1
    stack.pop
  rescue StandardError => e
    raise Error, "Invalid only= param: #{e.message}"
  end
end
