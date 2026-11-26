require "test_helper"

class BetaFeatureTest < ActiveSupport::TestCase
  context "BetaFeature" do
    setup do
      @feature = BetaFeature.new(name: "test_feature", label: "Test feature", description: "A feature for testing.", released_to: "production")
    end

    context "on production" do
      setup do
        Danbooru.config.stubs(:release_stage).returns("production")
      end

      should "be enabled only when its cookie is set to true" do
        assert_equal(true, @feature.enabled?({ "beta_feature_test_feature" => "true" }))
        assert_equal(false, @feature.enabled?({ "beta_feature_test_feature" => "false" }))
        assert_equal(false, @feature.enabled?({ "beta_feature_test_feature" => "1" }))
        assert_equal(false, @feature.enabled?({}))
      end
    end

    context "on testbooru or betabooru" do
      should "be enabled by default, unless its cookie is set to false" do
        %w[testbooru betabooru].each do |stage|
          Danbooru.config.stubs(:release_stage).returns(stage)

          assert_equal(true, @feature.enabled?({}))
          assert_equal(true, @feature.enabled?({ "beta_feature_test_feature" => "true" }))
          assert_equal(false, @feature.enabled?({ "beta_feature_test_feature" => "false" }))
        end
      end
    end

    context "the list of features" do
      setup do
        @testbooru_feature = BetaFeature.new(name: "testbooru_feature", label: "Testbooru", description: "Testbooru.", released_to: "testbooru")
        @betabooru_feature = BetaFeature.new(name: "betabooru_feature", label: "Betabooru", description: "Betabooru.", released_to: "betabooru")
        BetaFeature.stubs(:features).returns([@testbooru_feature, @betabooru_feature, @feature])
      end

      should "include every feature on testbooru" do
        Danbooru.config.stubs(:release_stage).returns("testbooru")
        assert_equal([@testbooru_feature, @betabooru_feature, @feature], BetaFeature.all)
      end

      should "include only betabooru and production features on betabooru" do
        Danbooru.config.stubs(:release_stage).returns("betabooru")
        assert_equal([@betabooru_feature, @feature], BetaFeature.all)
      end

      should "include only production features on production" do
        Danbooru.config.stubs(:release_stage).returns("production")
        assert_equal([@feature], BetaFeature.all)
      end

      should "treat an unknown release stage as production" do
        Danbooru.config.stubs(:release_stage).returns("bogus")
        assert_equal([@feature], BetaFeature.all)
        assert_equal(false, @feature.enabled?({}))
      end
    end

    should "define valid features with unique names" do
      names = BetaFeature.features.map(&:name)

      assert_equal(names.uniq, names)
    end

    should "only allow lowercase letters, numbers, and underscores in names" do
      assert_raises(ArgumentError) { BetaFeature.new(name: "bad'name", label: "Bad", description: "Bad.", released_to: "production") }
      assert_raises(ArgumentError) { BetaFeature.new(name: "Bad", label: "Bad", description: "Bad.", released_to: "production") }
      assert_raises(ArgumentError) { BetaFeature.new(name: "bad\nname", label: "Bad", description: "Bad.", released_to: "production") }
    end

    should "only allow known release stages" do
      assert_raises(ArgumentError) { BetaFeature.new(name: "bad", label: "Bad", description: "Bad.", released_to: "prod") }
      assert_raises(ArgumentError) { BetaFeature.new(name: "bad", label: "Bad", description: "Bad.", released_to: nil) }
    end

    should "find features by name" do
      Danbooru.config.stubs(:release_stage).returns("production")
      BetaFeature.stubs(:features).returns([@feature])

      assert_equal(@feature, BetaFeature.find("test_feature"))
      assert_nil(BetaFeature.find("nonexistent_feature"))
    end
  end
end
