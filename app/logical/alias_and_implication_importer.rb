class AliasAndImplicationImporter
  attr_accessor :text, :commands, :forum_id, :rename_aliased_pages

  def initialize(text, forum_id, rename_aliased_pages = "0")
    @forum_id = forum_id
    @text = text
    @rename_aliased_pages = rename_aliased_pages
  end

  def process!
    tokens = AliasAndImplicationImporter.tokenize(text)
    parse(tokens)
  end

  def rename_aliased_pages?
    @rename_aliased_pages == "1"
  end

  def self.tokenize(text)
    text = text.dup
    text.gsub!(/^\s+/, "")
    text.gsub!(/\s+$/, "")
    text.gsub!(/ {2,}/, " ")
    text.split(/\r\n|\r|\n/).map do |line|
      if line =~ /^create alias (\S+) -> (\S+)$/i
        [:create_alias, $1, $2]
      elsif line =~ /^create implication (\S+) -> (\S+)$/i
        [:create_implication, $1, $2]
      elsif line =~ /^remove alias (\S+) -> (\S+)$/i
        [:remove_alias, $1, $2]
      elsif line =~ /^remove implication (\S+) -> (\S+)$/i
        [:remove_implication, $1, $2]
      elsif line =~ /^mass update (.+?) -> (.*)$/i
        [:mass_update, $1, $2]
      elsif line.empty?
        # do nothing
      else
        raise "Unparseable line: #{line}"
      end
    end
  end

private

  def parse(tokens)
    ActiveRecord::Base.transaction do
      tokens.map do |token|
        case token[0]
        when :create_alias
          tag_alias = TagAlias.create(:forum_topic_id => forum_id, :status => "pending", :antecedent_name => token[1], :consequent_name => token[2])
          unless tag_alias.valid?
            raise "Error: #{tag_alias.errors.full_messages.join("; ")} (create alias #{tag_alias.antecedent_name} -> #{tag_alias.consequent_name})"
          end
          tag_alias.rename_wiki_and_artist if rename_aliased_pages?
          tag_alias.delay(:queue => "default").process!

        when :create_implication
          tag_implication = TagImplication.create(:forum_topic_id => forum_id, :status => "pending", :antecedent_name => token[1], :consequent_name => token[2])
          unless tag_implication.valid?
            raise "Error: #{tag_implication.errors.full_messages.join("; ")} (create implication #{tag_implication.antecedent_name} -> #{tag_implication.consequent_name})"
          end
          tag_implication.delay(:queue => "default").process!

        when :remove_alias
          tag_alias = TagAlias.where("antecedent_name = ?", token[1]).first
          raise "Alias for #{token[1]} not found" if tag_alias.nil?
          tag_alias.destroy

        when :remove_implication
          tag_implication = TagImplication.where("antecedent_name = ? and consequent_name = ?", token[1], token[2]).first
          raise "Implication for #{token[1]} not found" if tag_implication.nil?
          tag_implication.destroy

        when :mass_update
          Delayed::Job.enqueue(Moderator::TagBatchChange.new(token[1], token[2], CurrentUser.user, CurrentUser.ip_addr), :queue => "default")

        else
          raise "Unknown token: #{token[0]}"
        end
      end
    end
  end
end
