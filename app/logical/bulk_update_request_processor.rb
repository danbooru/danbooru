# frozen_string_literal: true

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
  validate :validate_script_length
  validate :validate_script

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
      when /\Adeprecate (\S+)\z/i
        [:deprecate, $1]
      when /\Aundeprecate (\S+)\z/i
        [:undeprecate, $1]
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
          validate_create_alias(args[0], args[1])

        when :create_implication
          validate_create_implication(args[0], args[1])

        when :remove_alias
          validate_remove_alias(args[0], args[1])

        when :remove_implication
          validate_remove_implication(args[0], args[1])

        when :change_category
          validate_change_category(args[0], args[1])

        when :rename
          validate_rename(args[0], args[1])

        when :mass_update
          validate_mass_update(args[0], args[1])

        when :nuke
          validate_nuke(args[0])

        when :deprecate
          validate_deprecate(args[0])

        when :undeprecate
          validate_undeprecate(args[0])

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

  def validate_create_alias(antecedent, consequent)
    tag_alias = TagAlias.new(creator: User.system, antecedent_name: antecedent, consequent_name: consequent)
    tag_alias.save(context: validation_context)
    if tag_alias.errors.present?
      errors.add(:base, "Can't create alias [[#{tag_alias.antecedent_name}]] -> [[#{tag_alias.consequent_name}]] (#{tag_alias.errors.full_messages.join("; ")})")
    end
  end

  def validate_remove_alias(antecedent, consequent)
    tag_alias = TagAlias.active.find_by(antecedent_name: antecedent, consequent_name: consequent)

    if validation_context == :approval
      # ignore non-existing aliases when approving a BUR
    elsif tag_alias.nil?
      errors.add(:base, "Can't remove alias [[#{antecedent}]] -> [[#{consequent}]] (alias doesn't exist)")
    else
      tag_alias.update(status: "deleted")
    end
  end

  def validate_create_implication(antecedent, consequent)
    tag_implication = TagImplication.new(creator: User.system, antecedent_name: antecedent, consequent_name: consequent, status: "active")
    tag_implication.save(context: validation_context)
    if tag_implication.errors.present?
      errors.add(:base, "Can't create implication [[#{tag_implication.antecedent_name}]] -> [[#{tag_implication.consequent_name}]] (#{tag_implication.errors.full_messages.join("; ")})")
    end
  end

  def validate_remove_implication(antecedent, consequent)
    tag_implication = TagImplication.active.find_by(antecedent_name: antecedent, consequent_name: consequent)

    if tag_implication.nil?
      # ignore non-existing implication when approving a BUR
      errors.add(:base, "Can't remove implication [[#{antecedent}]] -> [[#{consequent}]] (implication doesn't exist)") unless validation_context == :approval
    else
      tag_implication.update(status: "deleted")
    end
  end

  def validate_change_category(tag_name, category)
    tag = Tag.find_by_name(tag_name)
    if tag.nil?
      errors.add(:base, "Can't change category of [[#{tag_name}]] to #{category} ([[#{tag_name}]] doesn't exist)")
    end
  end

  def validate_rename(old_name, new_name)
    old_tag = Tag.find_by_name(old_name)
    new_tag = Tag.find_by_name(new_name) || Tag.new(name: new_name)

    if old_tag.nil?
      errors.add(:base, "Can't rename [[#{old_name}]] -> [[#{new_name}]] ([[#{old_name}]] doesn't exist)")
    elsif old_tag.post_count > MAXIMUM_RENAME_COUNT
      errors.add(:base, "Can't rename [[#{old_name}]] -> [[#{new_name}]] ([[#{old_name}]] has more than #{MAXIMUM_RENAME_COUNT} posts, use an alias instead)")
    elsif new_tag.invalid?(:name)
      errors.add(:base, "Can't rename [[#{old_name}]] -> [[#{new_name}]] (#{new_tag.errors.full_messages.join("; ")})")
    end
  end

  def validate_mass_update(first_search, second_search)
    first_query = PostQuery.new(first_search)

    if first_query.is_null_search?
      errors.add(:base, "Can't mass update {{#{first_search}}} -> {{#{second_search}}} (the search {{#{first_search}}} has a syntax error)")
    end
  end

  def validate_nuke(tag_or_pool)
    query = PostQuery.normalize(tag_or_pool)

    if query.is_metatag?(:pool)
      pool_name = query.find_metatag(:pool)
      if Pool.find_by_name(pool_name).nil?
        errors.add(:base, "Can't nuke {{#{tag_or_pool}}} (pool doesn't exist)")
      end
    end
  end

  def validate_deprecate(tag_name)
    tag = Tag.find_by_name(tag_name)

    if validation_context == :approval
      # ignore already deprecated tags and missing wikis when approving a tag deprecation.
    elsif tag.nil?
      errors.add(:base, "Can't deprecate [[#{tag_name}]] (tag doesn't exist)")
    elsif tag.is_deprecated?
      errors.add(:base, "Can't deprecate [[#{tag_name}]] (tag is already deprecated)")
    elsif tag.wiki_page.blank?
      errors.add(:base, "Can't deprecate [[#{tag_name}]] (tag must have a wiki page)")
    end
  end

  def validate_undeprecate(tag_name)
    tag = Tag.find_by_name(tag_name)

    if validation_context == :approval
      # ignore already deprecated tags when removing a tag deprecation.
    elsif tag.nil?
      errors.add(:base, "Can't undeprecate [[#{tag_name}]] (tag doesn't exist)")
    elsif !tag.is_deprecated?
      errors.add(:base, "Can't undeprecate [[#{tag_name}]] (tag is not deprecated)")
    end
  end

  # Validate that the script isn't too long.
  def validate_script_length
    if commands.size > MAXIMUM_SCRIPT_LENGTH
      errors.add(:base, "Bulk update request is too long (maximum size: #{MAXIMUM_SCRIPT_LENGTH} lines). Split your request into smaller chunks and try again.")
      throw :abort
    end
  end

  # Schedule the bulk update request to be processed later, in the background.
  def process_later!
    ProcessBulkUpdateRequestJob.perform_later(bulk_update_request)
  end

  # Process the bulk update request immediately.
  def process!
    CurrentUser.scoped(User.system) do
      bulk_update_request.update!(status: "processing")

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
          tag.update!(category: Tag.categories.value_for(args[1]), updater: User.system, is_bulk_update_request: true)

        when :deprecate
          tag = Tag.find_or_create_by_name(args[0])
          tag.update!(is_deprecated: true, updater: User.system)
          TagAlias.active.where(consequent_name: tag.name).each { |ti| ti.reject!(User.system) }
          TagImplication.active.where(consequent_name: tag.name).each { |ti| ti.reject!(User.system) }
          TagImplication.active.where(antecedent_name: tag.name).each { |ti| ti.reject!(User.system) }

        when :undeprecate
          tag = Tag.find_or_create_by_name(args[0])
          tag.update!(is_deprecated: false, updater: User.system)

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

  # The list of tags in the script. Used to search BURs by tag.
  # @return [Array<String>] the list of tags
  def affected_tags
    commands.flat_map do |command, *args|
      case command
      when :create_alias, :remove_alias, :create_implication, :remove_implication, :rename
        [args[0], args[1]]
      when :mass_update
        PostQuery.new(args[0]).tag_names + PostQuery.new(args[1]).tag_names
      when :nuke, :deprecate, :undeprecate
        PostQuery.new(args[0]).tag_names
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

        if PostQuery.normalize(args[0]).is_simple_tag?
          "nuke [[#{args[0]}]]"
        else
          "nuke {{#{args[0]}}}"
        end
      when :deprecate, :undeprecate
        "#{command} [[#{args[0]}]]"
      when :change_category
        "category [[#{args[0]}]] -> #{args[1]}"
      else
        # should never happen
        raise Error, "Unknown command: #{command}"
      end
    end.join("\n")
  end

  def self.nuke(tag_or_pool)
    # Reject existing implications from any other tag to the one we're nuking
    # otherwise the tag won't be removed from posts that have those other tags
    query = PostQuery.normalize(tag_or_pool)

    if query.is_simple_tag?
      TagImplication.active.where(consequent_name: tag_or_pool).each { |ti| ti.reject!(User.system) }
      TagImplication.active.where(antecedent_name: tag_or_pool).each { |ti| ti.reject!(User.system) }
    end

    if query.is_metatag?(:pool)
      pool_name = query.find_metatag(:pool)
      Pool.find_by_name(pool_name)&.update(is_deleted: true, post_ids: [])
    else
      mass_update(tag_or_pool, "-#{tag_or_pool}")
    end
  end

  def self.mass_update(antecedent, consequent, user: User.system)
    CurrentUser.scoped(user) do
      Post.anon_tag_match(antecedent).reorder(nil).parallel_find_each do |post|
        post.with_lock do
          post.tag_string += " " + consequent
          post.save
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
