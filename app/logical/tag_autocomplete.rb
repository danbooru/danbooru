module TagAutocomplete
  extend self

  PREFIX_BOUNDARIES = "(_/:;-"
  LIMIT = 10

  class Result < Struct.new(:name, :post_count, :category, :antecedent_name, :weight)
    def to_xml(options = {})
      to_h.to_xml(options)
    end
  end

  def search(query)
    query = Tag.normalize_name(query)

    candidates = count_sort(
      query,
      search_exact(query, 3) +
      search_prefix(query, 3) + 
      search_fuzzy(query, 3) +
      search_aliases(query, 3)
    )
  end

  def count_sort(query, words)
    words.uniq.slice(0, LIMIT).sort_by do |x|
      x.post_count.to_i * x.weight
    end.reverse
  end

  def search_exact(query, n=4)
    Tag
      .where("name like ? escape e'\\\\'", query.to_escaped_for_sql_like + "%")
      .where("post_count > 0")
      .order("post_count desc")
      .limit(n)
      .pluck(:name, :post_count, :category)
      .map {|row| Result.new(*row, 1.0)}
  end

  def search_fuzzy(query, n=5)
    if CurrentUser.id != 1
      return []
    end

    if query.size <= 3
      return []
    end

    Tag
      .where("name <% ?", query)
      .where("name like ? escape E'\\\\'", query[0].to_escaped_for_sql_like + '%')
      .where("post_count > 0")
      .order(Arel.sql("word_similarity(name, #{Tag.connection.quote(query)}) DESC"))
      .limit(n)
      .pluck(:name, :post_count, :category)
      .map {|row| Result.new(*row, 0.1)}
  end

  def search_prefix(query, n=3)
    if query.size >= 5
      return []
    end

    if query.size <= 1
      return []
    end

    if query =~ /[-_()]/
      return []
    end

    if query.size >= 3
      min_post_count = 0
    else
      min_post_count = 5_000
      n += 2
    end

    anchors = "^" + query.split("").map {|x| Regexp.escape(x)}.join(".*[#{PREFIX_BOUNDARIES}]")
    Tag
      .where("name ~ ?", anchors)
      .where("post_count > ?", min_post_count)
      .where("post_count > 0")
      .order("post_count desc")
      .limit(n)
      .pluck(:name, :post_count, :category)
      .map {|row| Result.new(*row, 0.8)}
  end

  def search_aliases(query, n=10)
    wildcard_name = query + "*"
    TagAlias
      .select("tags.name, tags.post_count, tags.category, tag_aliases.antecedent_name")
      .joins("INNER JOIN tags ON tags.name = tag_aliases.consequent_name")
      .where("tag_aliases.antecedent_name LIKE ? ESCAPE E'\\\\'", wildcard_name.to_escaped_for_sql_like)
      .active
      .where("tags.name NOT LIKE ? ESCAPE E'\\\\'", wildcard_name.to_escaped_for_sql_like)
      .where("tag_aliases.post_count > 0")
      .order("tag_aliases.post_count desc")
      .limit(n)
      .pluck(:name, :post_count, :category, :antecedent_name)
      .map {|row| Result.new(*row, 0.2)}
  end
end

