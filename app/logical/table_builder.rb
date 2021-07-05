# A helper class for building HTML tables. Used in views.
#
# @example
#   <%= table_for @tags do |table| %>
#     <% table.column :name do |tag| %>
#       <%= link_to_wiki "?", tag.name  %>
#       <%= link_to tag.name, posts_path(tags: tag.name) %>
#     <% end %>
#     <% table.column :post_count %>
#   <% end %>
#
# @see app/views/table_builder/_table.html.erb
class TableBuilder
  # Represents a single column in the table.
  class Column
    attr_reader :attribute, :name, :block, :header_attributes, :body_attributes

    # Define a table column.
    #
    # @example
    #   <% table.column :post_count %>
    #
    # @example
    #   <% table.column :name do |tag| %>
    #     <%= tag.pretty_name %>
    #   <% end %>
    #
    # @param attribute [Symbol] The attribute in the model the column is for.
    #   The column's name and value will come from this attribute by default.
    # @param name [String] the column's name, if different from the attribute name.
    # @param column [String] the column name
    # @param th [Hash] the HTML attributes for the column's <th> tag.
    # @param td [Hash] the HTML attributes for the column's <td> tag.
    # @param width [String] the HTML width value for the <th> tag.
    # @yieldparam item a block that returns the column value based on the item.
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

    # Returns the value of the table cell.
    # @param item [ApplicationRecord] the table cell item
    # @param i [Integer] the table row number
    # @param j [Integer] the table column number
    # @return [#to_s] the value of the table cell
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

  attr_reader :columns, :table_attributes, :row_attributes, :items

  # Build a table for an array of objects, one object per row.
  #
  # The <table> tag is automatically given an HTML id of the form `{name}-table`.
  # For example, `posts-table`, `tags-table`.
  #
  # The <tr> tag is automatically given an HTML id of the form `{name}-{id}`.
  # For example, `post-1234`, `tag-4567`, etc. Each <tr> tag also gets a set of
  # data attributes for each model; see #html_data_attributes in app/policies.
  #
  # @param items [Array<ApplicationRecord>] The list of ActiveRecord objects to
  #   build the table for. One item per table row.
  # @param tr [Hash] optional HTML attributes for the <tr> tag for each row
  # @param table_attributes [Hash] optional HTML attributes for the <table> tag
  # @yieldparam table [self] the table being built
  def initialize(items, tr: {}, **table_attributes)
    @items = items
    @columns = []
    @table_attributes = { class: "striped", **table_attributes }
    @row_attributes = tr

    if items.respond_to?(:model_name)
      @table_attributes[:id] ||= "#{items.model_name.plural.dasherize}-table"
    end

    yield self if block_given?
  end

  # Add a column to the table.
  # @example
  #   table.column(:name)
  def column(...)
    @columns << Column.new(...)
  end

  # Return the HTML attributes for each <tr> tag.
  # @param item [ApplicationRecord] the item for this row
  # @param i [Integer] the row number (unused)
  # @return [Hash] the <tr> attributes
  def all_row_attributes(item, i)
    return {} if !item.is_a?(ApplicationRecord)

    {
      id: "#{item.model_name.singular.dasherize}-#{item.id}",
      **row_attributes,
      **ApplicationController.helpers.data_attributes_for(item, "data", item.html_data_attributes)
    }
  end
end
