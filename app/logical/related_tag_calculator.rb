class RelatedTagCalculator
  def find_tags(tag, limit)
    ActiveRecord::Base.select_values_sql("SELECT tag_string FROM posts WHERE tag_index @@ to_tsquery('danbooru', ?) ORDER BY id DESC LIMIT ?", tag, limit)
  end
  
  def calculate_from_sample(name, limit, category_constraint = nil)
    counts = Hash.new {|h, k| h[k] = 0}
    
    find_tags(name, limit).each do |tags|
      tag_array = Tag.scan_tags(tags)
      if category_constraint
        categories = Tag.categories_for(tag_array)
        
        tag_array.each do |tag|
          if categories[tag] == category_constraint && tag != name
            counts[tag] += 1
          end
        end
      else
        tag_array.each do |tag|
          if tag != name
            counts[tag] += 1
          end
        end
      end
    end
    
    counts
  end
  
  def convert_hash_to_string(hash)
    hash.to_a.sort_by {|x| -x[1]}.flatten.join(" ")
  end
end
