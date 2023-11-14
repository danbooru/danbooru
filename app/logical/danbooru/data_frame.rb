# A wrapper around Rover::DataFrame that adds some extra utility methods.
#
# @see https://github.com/ankane/rover
module Danbooru
  class DataFrame
    attr_reader :df
    delegate :head, :shape, :names, :types, :rename, :empty?, :each_row, :[], :[]=, to: :df

    def initialize(...)
      @df = Rover::DataFrame.new(...)
    end

    # Replace ID columns with the actual object. For example, replace the `user_id` column with a `user` column containing User objects.
    def preload_associations(associations)
      associations.reduce(dup) do |table, association|
        primary_key = association.association_primary_key
        foreign_key = association.foreign_key
        name = association.name.to_s

        next table if !table.names.include?(foreign_key)

        ids = table[foreign_key].to_a.uniq.compact_blank
        records = association.klass.where(primary_key => ids).index_by(&primary_key.to_sym)

        table.rename({ foreign_key => name })
        table[name] = table[name].map { |id| records[id] }
        table
      end
    end

    def crosstab(index, pivot)
      return self if empty?

      new_df = DataFrame.new(index => df[index].uniq)

      df[pivot].uniq.to_a.each do |value|
        columns = df.types.keys.without(index, pivot)
        columns.each do |column|
          name = columns.one? ? value.to_s : "#{value}_#{column}"
          new_df[name] = df[df[pivot] == value][column]
        end
      end

      new_df
    end

    def as_json(*options)
      df.to_a
    end
  end
end
