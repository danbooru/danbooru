# Process a bulk update request. Parses the request and applies each line in
# sequence.
class BulkUpdateRequestProcessor
  # Maximum tag size allowed by the rename command before an alias must be used.
  MAXIMUM_RENAME_COUNT = 200

  # Maximum size of artist tags movable by builders.
  MAXIMUM_BUILDER_MOVE_COUNT = 200

  # Maximum number of lines a BUR may have.
  MAXIMUM_SCRIPT_LENGTH = 100

  include ActiveModel::Validations

  class Error < StandardError; end

  attr_reader :bulk_update_request

  delegate :script, :forum_topic, :approver, to: :bulk_update_request
  validate :validate_script
  validate :validate_script_length

  # @param bulk_update_request [BulkUpdateRequest] the BUR
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

  # Validate the bulk update request when it is created or approved.
  #
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

          if validation_context == :approval
            # ignore non-existing aliases when approving a BUR
          elsif tag_alias.nil?
            errors.add(:base, "Can't remove alias #{args[0]} -> #{args[1]} (alias doesn't exist)")
          else
            tag_alias.update(status: "deleted")
          end

        when :remove_implication
          tag_implication = TagImplication.active.find_by(antecedent_name: args[0], consequent_name: args[1])

          if validation_context == :approval
            # ignore non-existing implication when approving a BUR
          elsif tag_implication.nil?
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

  # Validate that the script isn't too long.
  def validate_script_length
    if commands.size > MAXIMUM_SCRIPT_LENGTH
      errors.add(:base, "Bulk update request is too long (maximum size: #{MAXIMUM_SCRIPT_LENGTH} lines). Split your request into smaller chunks and try again.")
    end
  end

  # Schedule the bulk update request to be processed later, in the background.
  def process_later!
    ProcessBulkUpdateRequestJob.perform_later(bulk_update_request)
  end

  # Process the bulk update request immediately.
  def process!
    CurrentUser.scoped(User.system, "127.0.0.1") do
      commands.map do |command, *args|
        case command
        when :create_alias
          TagAlias.approve!(antecedent_name: args[0], consequent_name: args[1], approver: approver, forum_topic: forum_topic)

        when :create_implication
          TagImplication.approve!(antecedent_name: args[0], consequent_name: args[1], approver: approver, forum_topic: forum_topic)

        when :remove_alias
          tag_alias = TagAlias.active.find_by(antecedent_name: args[0], consequent_name: args[1])
          tag_alias&.reject!(User.system)

        when :remove_implication
          tag_implication = TagImplication.active.find_by(antecedent_name: args[0], consequent_name: args[1])
          tag_implication&.reject!(User.system)

        when :mass_update
          BulkUpdateRequestProcessor.mass_update(args[0], args[1])

        when :nuke
          BulkUpdateRequestProcessor.nuke(args[0])

        when :rename
          TagMover.new(args[0], args[1], user: User.system).move!

        when :change_category
          tag = Tag.find_or_create_by_name(args[0])
          tag.update!(category: Tag.categories.value_for(args[1]))

        else
          # should never happen
          raise Error, "Unknown command: #{command}"
        end
      end

      bulk_update_request.update!(status: "approved")
    rescue StandardError
      bulk_update_request.update!(status: "failed")
      raise
    end
  end

  # The list of tags in the script. Used for search BURs by tag.
  # @return [Tag] the list of tags
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

  # Returns true if a non-Admin is allowed to approve a rename or alias request.
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

  # Convert the BUR to DText format.
  # @return [String]
  def to_dtext
    commands.map do |command, *args|
      case command
      when :create_alias, :create_implication, :remove_alias, :remove_implication, :rename
        "#{command.to_s.tr("_", " ")} [[#{args[0]}]] -> [[#{args[1]}]]"
      when :mass_update
        "mass update {{#{args[0]}}} -> {{#{args[1]}}}"
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

  def self.nuke(tag_name)
    # Reject existing implications from any other tag to the one we're nuking
    # otherwise the tag won't be removed from posts that have those other tags
    if PostQueryBuilder.new(tag_name).is_simple_tag?
      TagImplication.active.where(consequent_name: tag_name).each { |ti| ti.reject!(User.system) }
      TagImplication.active.where(antecedent_name: tag_name).each { |ti| ti.reject!(User.system) }
    end

    mass_update(tag_name, "-#{tag_name}")
  end

  def self.mass_update(antecedent, consequent, user: User.system)
    normalized_antecedent = PostQueryBuilder.new(antecedent).split_query
    normalized_consequent = PostQueryBuilder.new(consequent).parse_tag_edit

    CurrentUser.scoped(user) do
      Post.anon_tag_match(normalized_antecedent.join(" ")).reorder(nil).parallel_each do |post|
        post.with_lock do
          tags = (post.tag_array - normalized_antecedent + normalized_consequent).join(" ")
          post.update(tag_string: tags)
        end
      end
    end
  end

  # Tag move is allowed if:
  #
  # * The antecedent tag is an artist tag.
  # * The consequent_tag is a nonexistent tag, an empty tag (of any type), or an artist tag.
  # * Both tags have less than 200 posts.
  def self.is_tag_move_allowed?(antecedent_name, consequent_name)
    antecedent_tag = Tag.find_by_name(Tag.normalize_name(antecedent_name))
    consequent_tag = Tag.find_by_name(Tag.normalize_name(consequent_name))

    antecedent_allowed = antecedent_tag.present? && antecedent_tag.artist? && antecedent_tag.post_count < MAXIMUM_BUILDER_MOVE_COUNT
    consequent_allowed = consequent_tag.nil? || consequent_tag.empty? || (consequent_tag.artist? && consequent_tag.post_count < MAXIMUM_BUILDER_MOVE_COUNT)

    antecedent_allowed && consequent_allowed
  end
end
