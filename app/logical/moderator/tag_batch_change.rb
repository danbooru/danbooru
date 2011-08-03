module Moderator
  class TagBatchChange
    class Error < Exception ; end
    
    attr_reader :predicate, :consequent
    
    def initialize(predicate, consequent)
      @predicate = predicate
      @consequent = consequent
    end
    
    def execute
      raise Error.new("Predicate is missing") if predicate.blank?
      
      normalized_predicate = TagAlias.to_aliased(::Tag.scan_tags(predicate))
      normalized_consequent = TagAlias.to_aliased(::Tag.scan_tags(consequent))

      ::Post.tag_match(predicate).each do |post|
        tags = (post.tag_array - normalized_predicate + normalized_consequent).join(" ")
        post.update_attributes(:tag_string => tags)
      end
    end
  end
end
