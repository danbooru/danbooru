module TagAutocomplete
  module_function

  PREFIX_BOUNDARIES = "(_/:;-"
  LIMIT = 10

  Result = Struct.new(:name, :post_count, :category, :antecedent_name, :source) do
    include ActiveModel::Serializers::JSON
    include ActiveModel::Serializers::Xml

    def attributes
      (members + [:weight]).map { |x| [x.to_s, send(x)] }.to_h
    end

    def weight
      case source
      when :exact   then 1.0
      when :prefix  then 0.8
      when :alias   then 0.2
      when :correct then 0.1
      end
    end
  end

  def search(query)
    query = Tag.normalize_name(query)

    count_sort(
      search_exact(query, 8) +
      search_prefix(query, 4) +
      search_correct(query, 2) +
      search_aliases(query, 3)
    )
  end

  def count_sort(words)
    words.uniq(&:name).sort_by do |x|
      x.post_count * x.weight
    end.reverse.slice(0, LIMIT)
  end

  def search_exact(query, n = 4)
    Tag
      .where_like(:name, query + "*")
      .where("post_count > 0")
      .order("post_count desc")
      .limit(n)
      .pluck(:name, :post_count, :category)
      .map {|row| Result.new(*row, nil, :exact)}
  end

  def search_correct(query, n = 2)
    if query.size <= 3
      return []
    end

    Tag
      .where("name % ?", query)
      .where("abs(length(name) - ?) <= 3", query.size)
      .where_like(:name, query[0] + "*")
      .where("post_count > 0")
      .order(Arel.sql("similarity(name, #{Tag.connection.quote(query)}) DESC"))
      .limit(n)
      .pluck(:name, :post_count, :category)
      .map {|row| Result.new(*row, nil, :correct)}
  end

  def search_prefix(query, n = 3)
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

    regexp = "([a-z0-9])[a-z0-9']*($|[^a-z0-9']+)"
    Tag
      .where('regexp_replace(name, ?, ?, ?) like ?', regexp, '\1', 'g', query.to_escaped_for_sql_like + '%')
      .where("post_count > ?", min_post_count)
      .where("post_count > 0")
      .order("post_count desc")
      .limit(n)
      .pluck(:name, :post_count, :category)
      .map {|row| Result.new(*row, nil, :prefix)}
  end

  def search_aliases(query, n = 10)
    wildcard_name = query + "*"
    TagAlias
      .select("tags.name, tags.post_count, tags.category, tag_aliases.antecedent_name")
      .joins("INNER JOIN tags ON tags.name = tag_aliases.consequent_name")
      .where_like(:antecedent_name, wildcard_name)
      .active
      .where_not_like("tags.name", wildcard_name)
      .where("tags.post_count > 0")
      .order("tags.post_count desc")
      .limit(n)
      .pluck(:name, :post_count, :category, :antecedent_name)
      .map {|row| Result.new(*row, :alias)}
  end
end
