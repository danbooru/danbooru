class ImageHash < ApplicationRecord
  # XXX
  # belongs_to :post, foreign_key: :post_md5, primary_key: :md5
  belongs_to :post, foreign_key: :post_md5, primary_key: :md5, optional: true

  attr_accessor :comparison_hash

  concerning :InitializationMethods do
    class_methods do
      def new_from_source(params)
        if params[:file].present?
          file = params[:file]
          new_from_file(file)
        elsif params[:url].present?
          file, _ = Downloads::File.new(params[:url]).download!
          new_from_file(file)
        elsif params[:post_id].present?
          post = Post.find(params[:post_id])
          post.image_hash.clone.freeze.tap(&:readonly!)
        else
          nil
        end
      ensure
        file.try(:close)
      end

      def new_from_file(file)
        new(**ImageSimilarity.image_hashes(file))
      end

      def regen_posts(posts)
        posts.find_each do |post|
          next unless post.has_preview?

          preview_file = post.file(:preview)
          post.image_hash = new_from_file(preview_file)
          post.image_hash.save!
          preview_file.close
        end
      end

      def index_dir(dirname)
        Dir[dirname].each do |filename|
          file = File.open(filename)
          md5 = File.basename(filename).gsub(/\.jpg$/, "")

          image_hash = new_from_file(file)
          image_hash.post_md5 = md5
          image_hash.save!

          file.close
        end
      end
    end
  end

  concerning :SearchMethods do
    class_methods do
      def search_hash(target_hash, hash_type, max_results)
        if hash_type == :color_moment_hash
          image_hashes = ImageHash.order(Arel.sql("cube(color_moment_hash) <-> cube(array#{target_hash.to_s}) ASC")).limit(max_results)
        else
          target_hash_popcount = ImageSimilarity.popcount(target_hash)
          image_hashes = ImageHash.order(Arel.sql("cube(#{hash_type}_popcount) <#> cube(array#{target_hash_popcount.to_s}) ASC")).limit(max_results)
          sorted_hashes = image_hashes.sort_by { |h| ImageSimilarity.hamming_distance(h[hash_type], target_hash) }
          image_hashes.find_ordered(sorted_hashes.map(&:id))
        end
      end

      def search(params)
        q = super
        q = q.search_attributes(params, :md5, :post_md5, :phash, :block_mean_zero_hash, :marr_hildreth_hash, :color_moment_hash)

        if params[:image_hash]
          hash_type = params[:order]&.to_sym || :marr_hildreth_hash
          max_results = params[:max_results]&.to_i&.clamp(1, 1000) || 500
          target_hash = params[:image_hash][hash_type]

          q = q.search_hash(target_hash, hash_type, max_results)
        else
          q = q.apply_default_order(params)
        end

        q
      end
    end
  end

  concerning :SimilarityMethods do
    def phash_similarity
      ImageSimilarity.hamming_similarity(phash, comparison_hash.phash)
    end

    def block_mean_zero_similarity
      ImageSimilarity.hamming_similarity(block_mean_zero_hash, comparison_hash.block_mean_zero_hash)
    end

    def marr_hildreth_similarity
      ImageSimilarity.hamming_similarity(marr_hildreth_hash, comparison_hash.marr_hildreth_hash)
    end

    def color_moment_similarity
      ImageSimilarity.euclidean_similarity(color_moment_hash, comparison_hash.color_moment_hash)
    end
  end

  concerning :ApiMethods do
    def api_attributes
      list = super + [:post]
      list += [:phash_similarity, :block_mean_zero_similarity, :marr_hildreth_similarity, :color_moment_similarity] if comparison_hash.present?
      list
    end
  end
end
