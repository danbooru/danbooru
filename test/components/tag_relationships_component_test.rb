require "test_helper"

class TagRelationshipsComponentTest < ViewComponent::TestCase
  def render_component(tag)
    render_inline(TagRelationshipsComponent.new(tag: tag))
  end

  context "The TagRelationshipsComponent" do
    setup do
      @user = create(:user)
      @tag = create(:general_tag, name: "foo")
    end

    should "render nothing for a nil tag" do
      render_component(nil)

      assert_no_css(".fineprint")
    end

    should "render nothing for a tag without relationships" do
      render_component(@tag)

      assert_no_css(".fineprint")
    end

    should "show the tag the tag is aliased to" do
      create(:artist_tag, name: "new_name")
      as(@user) { create(:tag_alias, antecedent_name: "foo", consequent_name: "new_name", status: "active") }

      render_component(@tag.reload)

      assert_css(".fineprint", text: /This tag has been aliased to new_name/)
      assert_css(".fineprint a.wiki-link.tag-type-#{Tag.categories.artist}[href='/artists/show_or_new?name=new_name']")
    end

    should "list aliases and implications sorted by name and colored by category" do
      create(:copyright_tag, name: "touhou")
      as(@user) do
        create(:tag_alias, antecedent_name: "bbb", consequent_name: "foo", status: "active")
        create(:tag_alias, antecedent_name: "aaa", consequent_name: "foo", status: "active")
        create(:tag_implication, antecedent_name: "foo", consequent_name: "touhou", status: "active")
        create(:tag_implication, antecedent_name: "child", consequent_name: "foo", status: "active")
      end

      render_component(@tag.reload)

      assert_css(".fineprint", text: /The following tags are aliased to this tag: aaa and bbb/)
      assert_css(".fineprint", text: /This tag implicates touhou/)
      assert_css(".fineprint", text: /The following tags implicate this tag: child/)
      assert_css(".fineprint a.wiki-link.tag-type-#{Tag.categories.copyright}[href='/wiki_pages/touhou']")
    end

    should "list automatic tags colored by category" do
      create(:character_tag, name: "kiki")

      render_component(create(:general_tag, name: "kiki_(cosplay)"))

      assert_css(".fineprint", text: /This tag automatically adds kiki and cosplay/)
      assert_css(".fineprint a.wiki-link.tag-type-#{Tag.categories.character}[href='/wiki_pages/kiki']")
      assert_css(".fineprint a.wiki-link.tag-type-#{Tag.categories.general}[href='/wiki_pages/cosplay']")
    end

    should "not run extra queries for each alias or implication" do
      add_relationships = lambda do |n|
        as(@user) do
          create(:tag_alias, antecedent_name: "alias_#{n}", consequent_name: "foo", status: "active")
          create(:tag_implication, antecedent_name: "foo", consequent_name: "parent_#{n}", status: "active")
          create(:tag_implication, antecedent_name: "child_#{n}", consequent_name: "foo", status: "active")
        end
      end

      count_queries = lambda do
        count = 0
        ActiveSupport::Notifications.subscribed(->(*, payload) { count += 1 if payload[:sql].match?(/\ASELECT/) }, "sql.active_record") do
          render_component(Tag.find(@tag.id))
        end
        count
      end

      add_relationships.call(1)
      queries = count_queries.call
      add_relationships.call(2)
      add_relationships.call(3)

      assert_equal(queries, count_queries.call)
    end
  end
end
