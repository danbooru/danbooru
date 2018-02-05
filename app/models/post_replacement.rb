class PostReplacement < ApplicationRecord
  DELETION_GRACE_PERIOD = 30.days

  belongs_to :post
  belongs_to :creator, class_name: "User"
  before_validation :initialize_fields, on: :create
  attr_accessor :replacement_file, :final_source, :tags

  def initialize_fields
    self.creator = CurrentUser.user
    self.original_url = post.source
    self.tags = post.tag_string + " " + self.tags.to_s

    self.file_ext_was =  post.file_ext
    self.file_size_was = post.file_size
    self.image_width_was = post.image_width
    self.image_height_was = post.image_height
    self.md5_was = post.md5
  end

  def undo!
    undo_replacement = post.replacements.create(replacement_url: original_url)
    undo_replacement.process!
  end

  def process!
    transaction do
      upload = Upload.create!(
        file: replacement_file,
        source: replacement_url,
        rating: post.rating,
        tag_string: self.tags,
        replaced_post: post,
      )

      upload.process_upload
      upload.update(status: "completed", post_id: post.id)
      md5_changed = (upload.md5 != post.md5)

      if replacement_file.present?
        self.replacement_url = "file://#{replacement_file.original_filename}"
      else
        self.replacement_url = upload.downloaded_source
      end

      # queue the deletion *before* updating the post so that we use the old
      # md5/file_ext to delete the old files. if saving the post fails,
      # this is rolled back so the job won't run.
      if md5_changed
        Post.delay(queue: "default", run_at: Time.now + DELETION_GRACE_PERIOD).delete_files(post.id, post.file_path, post.large_file_path, post.preview_file_path)
      end

      self.file_ext = upload.file_ext
      self.file_size = upload.file_size
      self.image_height = upload.image_height
      self.image_width = upload.image_width
      self.md5 = upload.md5

      post.md5 = upload.md5
      post.file_ext = upload.file_ext
      post.image_width = upload.image_width
      post.image_height = upload.image_height
      post.file_size = upload.file_size
      post.source = final_source.presence || upload.source
      post.tag_string = upload.tag_string

      rescale_notes
      update_ugoira_frame_data(upload)

      if md5_changed
        post.comments.create!(creator: User.system, body: comment_replacement_message, do_not_bump_post: true)
      else
        post.queue_backup
      end

      save!
      post.save!
    end

    # point of no return: these things can't be rolled back, so we do them
    # only after the transaction successfully commits.
    post.distribute_files
    post.update_iqdb_async
  end

  def rescale_notes
    x_scale = post.image_width.to_f  / post.image_width_was.to_f
    y_scale = post.image_height.to_f / post.image_height_was.to_f

    post.notes.each do |note|
      note.rescale!(x_scale, y_scale)
    end
  end

  def update_ugoira_frame_data(upload)
    post.pixiv_ugoira_frame_data.destroy if post.pixiv_ugoira_frame_data.present?
    upload.ugoira_service.save_frame_data(post) if post.is_ugoira?
  end

  module SearchMethods
    def post_tags_match(query)
      PostQueryBuilder.new(query).build(self.joins(:post))
    end

    def search(params = {})
      q = super

      if params[:creator_id].present?
        q = q.where(creator_id: params[:creator_id].split(",").map(&:to_i))
      end

      if params[:creator_name].present?
        q = q.where(creator_id: User.name_to_id(params[:creator_name]))
      end

      if params[:post_id].present?
        q = q.where(post_id: params[:post_id].split(",").map(&:to_i))
      end

      if params[:post_tags_match].present?
        q = q.post_tags_match(params[:post_tags_match])
      end

      q.apply_default_order(params)
    end
  end

  module PresenterMethods
    def comment_replacement_message
      %("#{creator.name}":[/users/#{creator.id}] replaced this post with a new image:\n\n#{replacement_message})
    end

    def replacement_message
      linked_source = linked_source(replacement_url)
      linked_source_was = linked_source(post.source_was)

      <<-EOS.strip_heredoc
        [table]
          [tbody]
            [tr]
              [th]Old[/th]
              [td]#{linked_source_was}[/td]
              [td]#{post.md5_was}[/td]
              [td]#{post.file_ext_was}[/td]
              [td]#{post.image_width_was} x #{post.image_height_was}[/td]
              [td]#{post.file_size_was.to_s(:human_size, precision: 4)}[/td]
            [/tr]
            [tr]
              [th]New[/th]
              [td]#{linked_source}[/td]
              [td]#{post.md5}[/td]
              [td]#{post.file_ext}[/td]
              [td]#{post.image_width} x #{post.image_height}[/td]
              [td]#{post.file_size.to_s(:human_size, precision: 4)}[/td]
            [/tr]
          [/tbody]
        [/table]
      EOS
    end

    def linked_source(source)
      # truncate long sources in the middle: "www.pixiv.net...lust_id=23264933"
      truncated_source = source.gsub(%r{\Ahttps?://}, "").truncate(64, omission: "...#{source.last(32)}")

      if source =~ %r{\Ahttps?://}i
        %("#{truncated_source}":[#{source}])
      else
        truncated_source
      end
    end

    def suggested_tags_for_removal
      tags = post.tag_array.select { |tag| Danbooru.config.remove_tag_after_replacement?(tag) }
      tags = tags.map { |tag| "-#{tag}" }
      tags.join(" ")
    end
  end

  include PresenterMethods
  extend SearchMethods
end
