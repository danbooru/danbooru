class TableBuilder
  class Column
    attr_reader :attribute, :name, :block, :header_attributes, :body_attributes

    def initialize(attribute = nil, column: nil, th: {}, td: {}, width: nil, name: nil, &block)
      @attribute = attribute
      @column = column
      @header_attributes = { width: width, **th }
      @body_attributes = td
      @block = block

      @name = name || attribute
      @name = @name.to_s.titleize unless @name.is_a?(String)

      if @name.present? || @column.present?
        if @column.present?
          column_class = "#{@column}-column"
        else
          column_class = "#{@name.parameterize.dasherize}-column"
        end
        @header_attributes[:class] = "#{column_class} #{@header_attributes[:class]}".strip
        @body_attributes[:class] = "#{column_class} #{@body_attributes[:class]}".strip
      end
    end

    def value(item, i, j)
      if block.present?
        block.call(item, i, j, self)
        nil
      elsif attribute.is_a?(Symbol)
        item.send(attribute)
      else
        ""
      end
    end
  end

  attr_reader :columns, :table_attributes, :items

  def initialize(items, **table_attributes)
    @items = items
    @columns = []
    @table_attributes = { class: "striped", **table_attributes }

    if items.respond_to?(:model_name)
      @table_attributes[:id] ||= "#{items.model_name.plural.dasherize}-table"
    end

    yield self if block_given?
  end

  def column(...)
    @columns << Column.new(...)
  end

  def all_row_attributes(item, i)
    return {} if !item.is_a?(ApplicationRecord)

    {
      id: "#{item.model_name.singular.dasherize}-#{item.id}",
      **ApplicationController.helpers.data_attributes_for(item, "data", item.html_data_attributes)
    }
  end
end
