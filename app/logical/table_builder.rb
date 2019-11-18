class TableBuilder
  class Column
    attr_reader :attribute, :name, :block, :html_attributes

    def initialize(attribute = nil, name: attribute.to_s.titleize, **html_attributes, &block)
      @attribute = attribute
      @html_attributes = html_attributes
      @name = name
      @block = block
    end

    def value(item)
      if block.present?
        block.call(item, self)
        nil
      else
        item.send(attribute)
      end
    end
  end

  attr_reader :columns, :html_attributes, :items

  def initialize(items, **html_attributes)
    @items = items
    @columns = []
    @html_attributes = html_attributes
    yield self if block_given?
  end

  def column(*options, &block)
    @columns << Column.new(*options, &block)
  end

  def row_attributes(item)
    { id: "#{item.model_name.singular}-#{item.id}", "data-id": item.id }
  end
end
