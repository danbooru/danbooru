class TagImplication < TagRelationship
  MINIMUM_TAG_COUNT = 10
  MINIMUM_TAG_PERCENTAGE = 0.0001
  MAXIMUM_TAG_PERCENTAGE = 0.9

  has_many :child_implications, class_name: "TagImplication", primary_key: :consequent_name, foreign_key: :antecedent_name
  has_many :parent_implications, class_name: "TagImplication", primary_key: :antecedent_name, foreign_key: :consequent_name

  validates :antecedent_name, uniqueness: { scope: [:consequent_name, :status], conditions: -> { active }}
  validate :absence_of_circular_relation
  validate :absence_of_transitive_relation
  validate :antecedent_is_not_aliased
  validate :consequent_is_not_aliased
  validate :tag_categories_are_compatible, on: :request
  validate :meets_tag_size_requirements, on: :request
  validate :has_wiki_page, on: :request

  concerning :HierarchyMethods do
    class_methods do
      def ancestors_of(names)
        join_recursive do |query|
          query.start_with(antecedent_name: names).connect_by(consequent_name: :antecedent_name)
        end
      end

      def descendants_of(names)
        join_recursive do |query|
          query.start_with(consequent_name: names).connect_by(antecedent_name: :consequent_name)
        end
      end

      def tags_implied_by(names)
        Tag.where(name: active.ancestors_of(names).select(:consequent_name)).where.not(name: names)
      end

      def tags_implied_to(names)
        Tag.where(name: active.descendants_of(names).select(:antecedent_name))
      end
    end
  end

  concerning :SearchMethods do
    class_methods do
      def search(params)
        q = super

        if params[:implied_from].present?
          q = q.where(id: ancestors_of(params[:implied_from]).select(:id))
        end

        if params[:implied_to].present?
          q = q.where(id: descendants_of(params[:implied_to]).select(:id))
        end

        q
      end
    end
  end

  concerning :ValidationMethods do
    def absence_of_circular_relation
      return if is_rejected?

      # We don't want a -> b -> a chains
      implied_tags = TagImplication.tags_implied_by(consequent_name).map(&:name)
      if implied_tags.include?(antecedent_name)
        errors.add(:base, "Tag implication can not create a circular relation with another tag implication")
      end
    end

    # If we already have a -> b -> c, don't allow a -> c.
    def absence_of_transitive_relation
      return if is_rejected?

      # Find everything else the antecedent implies, not including the current implication.
      implications = TagImplication.active.where("NOT (tag_implications.antecedent_name = ? AND tag_implications.consequent_name = ?)", antecedent_name, consequent_name)
      implied_tags = implications.tags_implied_by(antecedent_name).map(&:name)

      if implied_tags.include?(consequent_name)
        errors.add(:base, "#{antecedent_name} already implies #{consequent_name} through another implication")
      end
    end

    def antecedent_is_not_aliased
      return if is_rejected?

      # We don't want to implicate a -> b if a is already aliased to c
      if TagAlias.active.exists?(["antecedent_name = ?", antecedent_name])
        errors.add(:base, "Antecedent tag must not be aliased to another tag")
      end
    end

    def consequent_is_not_aliased
      return if is_rejected?

      # We don't want to implicate a -> b if b is already aliased to c
      if TagAlias.active.exists?(["antecedent_name = ?", consequent_name])
        errors.add(:base, "Consequent tag must not be aliased to another tag")
      end
    end

    def tag_categories_are_compatible
      if antecedent_tag.category != consequent_tag.category
        errors.add(:base, "Can't imply a #{antecedent_tag.category_name.downcase} tag to a #{consequent_tag.category_name.downcase} tag")
      end
    end

    # Require tags to have at least 10 posts or be at least 0.01% the size of
    # the parent tag, and not make up more than 90% of the parent tag. Only
    # applies to general tags. Doesn't apply when either tag is empty to allow
    # implying new tags.
    def meets_tag_size_requirements
      return unless antecedent_tag.general?
      return if antecedent_tag.empty? || consequent_tag.empty?

      if antecedent_tag.post_count < MINIMUM_TAG_COUNT
        errors.add(:base, "'#{antecedent_name}' must have at least #{MINIMUM_TAG_COUNT} posts")
      elsif antecedent_tag.post_count < (MINIMUM_TAG_PERCENTAGE * consequent_tag.post_count)
        errors.add(:base, "'#{antecedent_name}' must have at least #{(MINIMUM_TAG_PERCENTAGE * consequent_tag.post_count).to_i} posts")
      end

      max_count = MAXIMUM_TAG_PERCENTAGE * PostQueryBuilder.new("~#{antecedent_name} ~#{consequent_name}").fast_count(timeout: 0).to_i
      if antecedent_tag.post_count > max_count && max_count > 0
        errors.add(:base, "'#{antecedent_name}' can't make up than #{(MAXIMUM_TAG_PERCENTAGE * 100).to_i}% of '#{consequent_name}'")
      end
    end

    def has_wiki_page
      if !antecedent_tag.empty? && antecedent_wiki.blank?
        errors.add(:base, "'#{antecedent_name}' must have a wiki page")
      end

      if !consequent_tag.empty? && consequent_wiki.blank?
        errors.add(:base, "'#{consequent_name}' must have a wiki page")
      end
    end
  end

  concerning :ApprovalMethods do
    def process!
      update_posts!
    end

    def update_posts!
      CurrentUser.scoped(User.system) do
        Post.system_tag_match("#{antecedent_name} -#{consequent_name}").find_each do |post|
          post.lock!
          post.save!
        end
      end
    end
  end
end
