class BulkUpdateRequestProcessor
  extend Memoist

  class Error < StandardError; end
  attr_accessor :text, :forum_topic_id, :skip_secondary_validations

  def initialize(text, forum_topic_id: nil, skip_secondary_validations: true)
    @forum_topic_id = forum_topic_id
    @text = text
    @skip_secondary_validations = skip_secondary_validations
  end

  def tokens
    text.split(/\r\n|\r|\n/).reject(&:blank?).map do |line|
      line = line.gsub(/[[:space:]]+/, " ").strip

      if line =~ /^(?:create alias|aliasing|alias) (\S+) -> (\S+)$/i
        [:create_alias, $1, $2]
      elsif line =~ /^(?:create implication|implicating|implicate|imply) (\S+) -> (\S+)$/i
        [:create_implication, $1, $2]
      elsif line =~ /^(?:remove alias|unaliasing|unalias) (\S+) -> (\S+)$/i
        [:remove_alias, $1, $2]
      elsif line =~ /^(?:remove implication|unimplicating|unimplicate|unimply) (\S+) -> (\S+)$/i
        [:remove_implication, $1, $2]
      elsif line =~ /^(?:mass update|updating|update|change) (.+?) -> (.*)$/i
        [:mass_update, $1, $2]
      elsif line =~ /^category (\S+) -> (#{Tag.categories.regexp})/
        [:change_category, $1, $2]
      elsif line.strip.empty?
        # do nothing
      else
        raise Error, "Unparseable line: #{line}"
      end
    end
  end

  def validate!
    tokens.map do |token|
      case token[0]
      when :create_alias
        tag_alias = TagAlias.new(creator: User.system, forum_topic_id: forum_topic_id, status: "pending", antecedent_name: token[1], consequent_name: token[2], skip_secondary_validations: skip_secondary_validations)
        unless tag_alias.valid?
          raise Error, "Error: #{tag_alias.errors.full_messages.join("; ")} (create alias #{tag_alias.antecedent_name} -> #{tag_alias.consequent_name})"
        end

      when :create_implication
        tag_implication = TagImplication.new(creator: User.system, forum_topic_id: forum_topic_id, status: "pending", antecedent_name: token[1], consequent_name: token[2], skip_secondary_validations: skip_secondary_validations)
        unless tag_implication.valid?
          raise Error, "Error: #{tag_implication.errors.full_messages.join("; ")} (create implication #{tag_implication.antecedent_name} -> #{tag_implication.consequent_name})"
        end

      when :remove_alias, :remove_implication, :mass_update, :change_category
        # okay

      else
        raise NotImplementedError, "Unknown token: #{token[0]}" # should never happen
      end
    end
  end

  def process!(approver)
    ActiveRecord::Base.transaction do
      tokens.map do |token|
        case token[0]
        when :create_alias
          tag_alias = TagAlias.create(creator: approver, forum_topic_id: forum_topic_id, status: "pending", antecedent_name: token[1], consequent_name: token[2], skip_secondary_validations: skip_secondary_validations)
          unless tag_alias.valid?
            raise Error, "Error: #{tag_alias.errors.full_messages.join("; ")} (create alias #{tag_alias.antecedent_name} -> #{tag_alias.consequent_name})"
          end
          tag_alias.approve!(approver: approver)

        when :create_implication
          tag_implication = TagImplication.create(creator: approver, forum_topic_id: forum_topic_id, status: "pending", antecedent_name: token[1], consequent_name: token[2], skip_secondary_validations: skip_secondary_validations)
          unless tag_implication.valid?
            raise Error, "Error: #{tag_implication.errors.full_messages.join("; ")} (create implication #{tag_implication.antecedent_name} -> #{tag_implication.consequent_name})"
          end
          tag_implication.approve!(approver: approver)

        when :remove_alias
          tag_alias = TagAlias.active.find_by(antecedent_name: token[1], consequent_name: token[2])
          raise Error, "Alias for #{token[1]} not found" if tag_alias.nil?
          tag_alias.reject!

        when :remove_implication
          tag_implication = TagImplication.active.find_by(antecedent_name: token[1], consequent_name: token[2])
          raise Error, "Implication for #{token[1]} not found" if tag_implication.nil?
          tag_implication.reject!

        when :mass_update
          TagBatchChangeJob.perform_later(token[1], token[2], User.system, "127.0.0.1")

        when :change_category
          tag = Tag.find_or_create_by_name(token[1])
          tag.category = Tag.categories.value_for(token[2])
          tag.save

        else
          raise Error, "Unknown token: #{token[0]}"
        end
      end
    end
  end

  def affected_tags
    tokens.flat_map do |type, *args|
      case type
      when :create_alias, :remove_alias, :create_implication, :remove_implication
        [args[0], args[1]]
      when :mass_update
        tags = PostQueryBuilder.new(args[0]).tags + PostQueryBuilder.new(args[1]).tags
        tags.reject(&:negated).reject(&:optional).reject(&:wildcard).map(&:name)
      when :change_category
        args[0]
      end
    end.sort.uniq
  rescue Error
    []
  end

  def is_tag_move_allowed?
    tokens.all? do |type, *args|
      case type
      when :create_alias
        BulkUpdateRequestProcessor.is_tag_move_allowed?(args[0], args[1])
      when :mass_update
        lhs = PostQueryBuilder.new(args[0])
        rhs = PostQueryBuilder.new(args[1])

        lhs.is_simple_tag? && rhs.is_simple_tag? && BulkUpdateRequestProcessor.is_tag_move_allowed?(args[0], args[1])
      else
        false
      end
    end
  end

  def to_dtext
    tokens.map do |token|
      case token[0]
      when :create_alias, :create_implication, :remove_alias, :remove_implication
        "#{token[0].to_s.tr("_", " ")} [[#{token[1]}]] -> [[#{token[2]}]]"
      when :mass_update
        "mass update {{#{token[1]}}} -> #{token[2]}"
      when :change_category
        "category [[#{token[1]}]] -> #{token[2]}"
      else
        raise "Unknown token: #{token[0]}"
      end
    end.join("\n")
  end

  def self.is_tag_move_allowed?(antecedent_name, consequent_name)
    antecedent_tag = Tag.find_by_name(Tag.normalize_name(antecedent_name))
    consequent_tag = Tag.find_by_name(Tag.normalize_name(consequent_name))

    (antecedent_tag.blank? || antecedent_tag.empty? || (antecedent_tag.artist? && antecedent_tag.post_count <= 100)) &&
    (consequent_tag.blank? || consequent_tag.empty? || (consequent_tag.artist? && consequent_tag.post_count <= 100))
  end

  memoize :tokens
end
