class TableBuilder
  class Column
    attr_reader :attribute, :name, :block, :header_attributes, :body_attributes, :is_html_safe

    def initialize(attribute = nil, header_attributes=nil, body_attributes=nil, is_html_safe=false, &block)
      @attribute = attribute
      @header_attributes = header_attributes
      @body_attributes = body_attributes
      @name = attribute.kind_of?(String) ? attribute : attribute.to_s.titleize
      @is_html_safe = is_html_safe
      @block = block
    end

    def value(item, i, j)
      if block.present?
        block.call(item, i, j, self)
        nil
      elsif attribute.kind_of?(Symbol)
        item.send(attribute)
      else
        ""
      end
    end
  end

  attr_reader :columns, :table_attributes, :items

  def initialize(items, table_attributes=nil)
    @items = items
    @columns = []
    @table_attributes = table_attributes
    yield self if block_given?
  end

  def column(*options, &block)
    @columns << Column.new(*options, &block)
  end

  def all_row_attributes(item, i)
    if !item.id.nil?
      standard_attributes = { id: "#{item.model_name.singular.dasherize}-#{item.id}", "data-id": item.id }
    else
      standard_attributes = {}
    end

    if item.html_data_attributes.length > 0
      class_attributes = ApplicationController.helpers.data_attributes_for(item, "data", item.html_data_attributes)
    else
      class_attributes = {}
    end

    standard_attributes.merge(class_attributes)
  end
end
