class TagNameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    case Tag.normalize_name(value)
    when /\A_*\z/
      record.errors[attribute] << "'#{value}' cannot be blank"
    when /\*/
      record.errors[attribute] << "'#{value}' cannot contain asterisks ('*')"
    when /,/
      record.errors[attribute] << "'#{value}' cannot contain commas (',')"
    when /\A~/
      record.errors[attribute] << "'#{value}' cannot begin with a tilde ('~')"
    when /\A-/
      record.errors[attribute] << "'#{value}' cannot begin with a dash ('-')"
    when /\A_/
      record.errors[attribute] << "'#{value}' cannot begin with an underscore"
    when /_\z/
      record.errors[attribute] << "'#{value}' cannot end with an underscore"
    when /__/
      record.errors[attribute] << "'#{value}' cannot contain consecutive underscores"
    when /[^[:graph:]]/
      record.errors[attribute] << "'#{value}' cannot contain non-printable characters"
    when /[^[:ascii:]]/
      record.errors[attribute] << "'#{value}' must consist of only ASCII characters"
    when /\A(#{PostQueryBuilder::METATAGS.join("|")}):(.+)\z/i
      record.errors[attribute] << "'#{value}' cannot begin with '#{$1}:'"
    when /\A(#{Tag.categories.regexp}):(.+)\z/i
      record.errors[attribute] << "'#{value}' cannot begin with '#{$1}:'"
    when "new", "search"
      record.errors[attribute] << "'#{value}' is a reserved name and cannot be used"
    when /\A(.+)_\(cosplay\)\z/i
      tag_name = TagAlias.to_aliased([$1]).first
      tag = Tag.find_by_name(tag_name)

      if tag.present? && !tag.empty? && !tag.character?
        record.errors[attribute] << "#{tag_name} must be a character tag"
      end
    end
  end
end
