class RelatedTagCalculator
  def find_tags(tag, limit)
    Post.find_by_tags(tag, :limit => limit, :select => "posts.tag_string", :order => "posts.md5").map(&:tag_string)
  end
  
  def calculate_from_sample(name, limit, category_constraint = nil)
    counts = Hash.new {|h, k| h[k] = 0}
    
    case category_constraint
    when Tag.categories.artist
      limit *= 5
      
    when Tag.categories.copyright
      limit *= 4
    
    when Tag.categories.character
      limit *= 3
    end
    
    find_tags(name, limit).each do |tags|
      tag_array = Tag.scan_tags(tags)
      if category_constraint
        tag_array.each do |tag|
          category = Tag.category_for(tag)
          if category == category_constraint
            counts[tag] += 1
          end
        end
      else
        tag_array.each do |tag|
          counts[tag] += 1
        end
      end
    end
    
    counts
  end
  
  def convert_hash_to_array(hash)
    hash.to_a.sort_by {|x| -x[1]}.slice(0, 25)
  end
  
  def convert_hash_to_string(hash)
    convert_hash_to_array(hash).flatten.join(" ")
  end
end
