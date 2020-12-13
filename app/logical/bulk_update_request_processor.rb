class BulkUpdateRequestProcessor
  MAXIMUM_RENAME_COUNT = 200
  MAXIMUM_SCRIPT_LENGTH = 100

  include ActiveModel::Validations

  class Error < StandardError; end

  attr_reader :bulk_update_request
  delegate :script, :forum_topic, to: :bulk_update_request
  validate :validate_script
  validate :validate_script_length

  def initialize(bulk_update_request)
    @bulk_update_request = bulk_update_request
  end

  # Parse the script into a list of commands.
  def commands
    script.split(/\r\n|\r|\n/).reject(&:blank?).map do |line|
      line = line.gsub(/[[:space:]]+/, " ").strip
      next if line.empty?

      case line
      when /\A(?:create alias|alias) (\S+) -> (\S+)\z/i
        [:create_alias, Tag.normalize_name($1), Tag.normalize_name($2)]
      when /\A(?:create implication|imply) (\S+) -> (\S+)\z/i
        [:create_implication, Tag.normalize_name($1), Tag.normalize_name($2)]
      when /\A(?:remove alias|unalias) (\S+) -> (\S+)\z/i
        [:remove_alias, Tag.normalize_name($1), Tag.normalize_name($2)]
      when /\A(?:remove implication|unimply) (\S+) -> (\S+)\z/i
        [:remove_implication, Tag.normalize_name($1), Tag.normalize_name($2)]
      when /\Arename (\S+) -> (\S+)\z/i
        [:rename, Tag.normalize_name($1), Tag.normalize_name($2)]
      when /\A(?:mass update|update) (.+?) -> (.*)\z/i
        [:mass_update, $1, $2]
      when /\Acategory (\S+) -> (#{Tag.categories.regexp})\z/i
        [:change_category, Tag.normalize_name($1), $2.downcase]
      when /\Anuke (\S+)\z/i
        [:nuke, $1]
      else
        [:invalid_line, line]
      end
    end
  end

  # validation_context will be either :request (when the BUR is first created
  # or edited) or :approval (when the BUR is approved). Certain validations
  # only run when the BUR is requested, not when it's approved.
  def validate_script
    BulkUpdateRequest.transaction(requires_new: true) do
      commands.each do |command, *args|
        case command
        when :create_alias
          tag_alias = TagAlias.new(creator: User.system, antecedent_name: args[0], consequent_name: args[1])
          tag_alias.save(context: validation_context)
          if tag_alias.errors.present?
            errors.add(:base, "Can't create alias #{tag_alias.antecedent_name} -> #{tag_alias.consequent_name} (#{tag_alias.errors.full_messages.join("; ")})")
          end

        when :create_implication
          tag_implication = TagImplication.new(creator: User.system, antecedent_name: args[0], consequent_name: args[1], status: "active")
          tag_implication.save(context: validation_context)
          if tag_implication.errors.present?
            errors.add(:base, "Can't create implication #{tag_implication.antecedent_name} -> #{tag_implication.consequent_name} (#{tag_implication.errors.full_messages.join("; ")})")
          end

        when :remove_alias
          tag_alias = TagAlias.active.find_by(antecedent_name: args[0], consequent_name: args[1])
          if tag_alias.nil?
            errors.add(:base, "Can't remove alias #{args[0]} -> #{args[1]} (alias doesn't exist)")
          else
            tag_alias.update(status: "deleted")
          end

        when :remove_implication
          tag_implication = TagImplication.active.find_by(antecedent_name: args[0], consequent_name: args[1])
          if tag_implication.nil?
            errors.add(:base, "Can't remove implication #{args[0]} -> #{args[1]} (implication doesn't exist)")
          else
            tag_implication.update(status: "deleted")
          end

        when :change_category
          tag = Tag.find_by_name(args[0])
          if tag.nil?
            errors.add(:base, "Can't change category #{args[0]} -> #{args[1]} (the '#{args[0]}' tag doesn't exist)")
          end

        when :rename
          tag = Tag.find_by_name(args[0])
          if tag.nil?
            errors.add(:base, "Can't rename #{args[0]} -> #{args[1]} (the '#{args[0]}' tag doesn't exist)")
          elsif tag.post_count > MAXIMUM_RENAME_COUNT
            errors.add(:base, "Can't rename #{args[0]} -> #{args[1]} ('#{args[0]}' has more than #{MAXIMUM_RENAME_COUNT} posts, use an alias instead)")
          end

        when :mass_update, :nuke
          # okay

        when :invalid_line
          errors.add(:base, "Invalid line: #{args[0]}")

        else
          # should never happen
          raise Error, "Unknown command: #{command}"
        end
      end

      raise ActiveRecord::Rollback
    end
  end

  def validate_script_length
    if commands.size > MAXIMUM_SCRIPT_LENGTH
      errors.add(:base, "Bulk update request is too long (maximum size: #{MAXIMUM_SCRIPT_LENGTH} lines). Split your request into smaller chunks and try again.")
    end
  end

  def process!(approver)
    ActiveRecord::Base.transaction do
      commands.map do |command, *args|
        case command
        when :create_alias
          TagAlias.approve!(antecedent_name: args[0], consequent_name: args[1], approver: approver, forum_topic: forum_topic)

        when :create_implication
          TagImplication.approve!(antecedent_name: args[0], consequent_name: args[1], approver: approver, forum_topic: forum_topic)

        when :remove_alias
          tag_alias = TagAlias.active.find_by!(antecedent_name: args[0], consequent_name: args[1])
          tag_alias.reject!

        when :remove_implication
          tag_implication = TagImplication.active.find_by!(antecedent_name: args[0], consequent_name: args[1])
          tag_implication.reject!

        when :mass_update
          TagBatchChangeJob.perform_later(args[0], args[1])

        when :nuke
          TagBatchChangeJob.perform_later(args[0], "-#{args[0]}")

        when :rename
          TagRenameJob.perform_later(args[0], args[1])

        when :change_category
          tag = Tag.find_or_create_by_name(args[0])
          tag.update!(category: Tag.categories.value_for(args[1]))

        else
          # should never happen
          raise Error, "Unknown command: #{command}"
        end
      end
    end
  end

  def affected_tags
    commands.flat_map do |command, *args|
      case command
      when :create_alias, :remove_alias, :create_implication, :remove_implication, :rename
        [args[0], args[1]]
      when :mass_update
        tags = PostQueryBuilder.new(args[0]).tags + PostQueryBuilder.new(args[1]).tags
        tags.reject(&:negated).reject(&:optional).reject(&:wildcard).map(&:name)
      when :nuke
        PostQueryBuilder.new(args[0]).tags.map(&:name)
      when :change_category
        args[0]
      end
    end.sort.uniq
  end

  def is_tag_move_allowed?
    commands.all? do |command, *args|
      case command
      when :create_alias, :rename
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
    commands.map do |command, *args|
      case command
      when :create_alias, :create_implication, :remove_alias, :remove_implication, :rename
        "#{command.to_s.tr("_", " ")} [[#{args[0]}]] -> [[#{args[1]}]]"
      when :mass_update
        "mass update {{#{args[0]}}} -> #{args[1]}"
      when :nuke
        query = PostQueryBuilder.new(args[0])

        if query.is_simple_tag?
          "nuke [[#{args[0]}]]"
        else
          "nuke {{#{args[0]}}}"
        end
      when :change_category
        "category [[#{args[0]}]] -> #{args[1]}"
      else
        # should never happen
        raise Error, "Unknown command: #{command}"
      end
    end.join("\n")
  end

  def self.is_tag_move_allowed?(antecedent_name, consequent_name)
    antecedent_tag = Tag.find_by_name(Tag.normalize_name(antecedent_name))
    consequent_tag = Tag.find_by_name(Tag.normalize_name(consequent_name))

    (antecedent_tag.blank? || antecedent_tag.empty? || (antecedent_tag.artist? && antecedent_tag.post_count <= 100)) &&
    (consequent_tag.blank? || consequent_tag.empty? || (consequent_tag.artist? && consequent_tag.post_count <= 100))
  end
end
