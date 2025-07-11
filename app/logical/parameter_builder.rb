# frozen_string_literal: true

class ParameterBuilder
  def self.serial_parameters(only_string, object)
    only_array = split_only_string(only_string)
    get_only_hash(only_array, object)
  end

  def self.get_only_hash(only_array, object, seen_objects = [])
    return {} if object.nil?
    is_root = seen_objects.length == 0
    only_hash = {only: [], include: [], methods: []}
    available_includes = object.available_includes
    attributes, methods = object.api_attributes.partition { |attr| object.has_attribute?(attr) }
    methods -= available_includes
    # Attributes and/or methods may be included in the final pass, but not includes
    seen_objects << object.class.name
    only_array.each do |item|
      match = item.match(/(\w+)\[(.+?)\]$/)
      item = (match || [])[1] || item
      item_sym = item.to_sym
      was_seen = was_inclusion_seen(item, object.class, seen_objects)
      if match && available_includes.include?(item_sym) && (!was_seen || is_root)
        item_object = object.send(item_sym)
        next if item_object.nil?
        item_array = split_only_string(match[2])
        item_objects = item_object.is_a?(ActiveRecord::Relation) ? item_object : [item_object]
        item_hash = item_objects.map do |item_object|
          get_only_hash(item_array, item_object, seen_objects.clone)
        end.reduce do |memo, item_hash|
          merge_only_hash(memo, item_hash)
        end
        only_hash[:include] << Hash[item_sym, item_hash]
      elsif available_includes.include?(item_sym) && (!was_seen || is_root)
        only_hash[:include] << item_sym
      elsif attributes.include?(item_sym)
        only_hash[:only] << item_sym
      elsif methods.include?(item_sym)
        only_hash[:methods] << item_sym
        only_hash[:only] << item_sym
      end
    end
    only_hash.delete(:include) if only_hash[:include].empty?
    only_hash.delete(:methods) if only_hash[:methods].empty?
    only_hash
  end

  def self.includes_parameters(only_string, model_name)
    return [] if only_string.blank?

    only_array = split_only_string(only_string)
    get_includes_array(only_array, model_name)
  end

  def self.get_includes_array(only_array, model_name, seen_objects = [])
    is_root = seen_objects.length == 0
    include_array = []
    model = Kernel.const_get(model_name)
    available_includes = model.available_includes
    # Attributes and/or methods may be included in the final pass, but not includes
    seen_objects << model_name
    only_array.each do |item|
      match = item.match(/(\w+)\[(.+?)\]$/)
      item = (match || [])[1] || item
      item_sym = item.to_sym
      was_seen = was_inclusion_seen(item, model, seen_objects)
      if match && available_includes.include?(item_sym) && (!was_seen || is_root)
        item_array = split_only_string(match[2])
        model.associated_models(item).each do |m|
          item_array = get_includes_array(item_array, m, seen_objects.clone)
          include_array << (item_array.empty? ? item_sym : Hash[item_sym, item_array])
        end
      elsif available_includes.include?(item_sym) && (!was_seen || is_root)
        include_array << item_sym
      end
    end
    include_array
  end

  def self.was_inclusion_seen(inclusion, class_object, seen_objects)
    if class_object.reflections[inclusion]
      inclusion_class = class_object.reflections[inclusion].class_name
      max_seen = (class_object.multiple_includes.include?(inclusion.to_sym) ? 1 : 0)
      seen_objects.count(inclusion_class) > max_seen
    else
      false
    end
  end

  def self.split_only_string(only_string)
    only_array = []
    offset = 0
    position = 0
    level = 0
    loop do
      str = only_string[Range.new(position, -1)]
      match = str.match(/[,\[\]]/)
      break unless match
      start_pos, end_pos = match.offset(0)
      if match[0] == "," && level.zero?
        only_array << only_string[Range.new(offset, position + start_pos - 1)]
        offset = position + end_pos
      elsif match[0] == "["
        level += 1
      elsif match[0] == "]"
        level -= 1
      end
      position += end_pos
    end
    only_array << only_string[Range.new(offset, -1)]
  end

  def self.merge_only_hash(h1, h2)
    h1.merge(h2) do |key, v1, v2|
      if v1.is_a?(Hash) && v2.is_a?(Hash)
        merge_only_hash(v1, v2)
      elsif v1.is_a?(Array) && v2.is_a?(Array)
        v1 | v2
      else
        v2
      end
    end
  end
end
