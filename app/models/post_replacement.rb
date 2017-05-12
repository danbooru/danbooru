class PostReplacement < ActiveRecord::Base
  DELETION_GRACE_PERIOD = 30.days

  belongs_to :post
  belongs_to :creator, class_name: "User"
  before_validation :initialize_fields
  attr_accessible :replacement_url

  def initialize_fields
    self.creator = CurrentUser.user
    self.original_url = post.source
  end

  def undo!
    undo_replacement = post.replacements.create(replacement_url: original_url)
    undo_replacement.process!
  end

  def process!
    # TODO for posts with notes we need to rescale the notes if the dimensions change.
    if post.notes.any?
      raise NotImplementedError.new("Replacing images with notes not yet supported.")
    end

    # TODO for ugoiras we need to replace the frame data.
    if post.is_ugoira?
      raise NotImplementedError.new("Replacing ugoira images not yet supported.")
    end

    # TODO images hosted on s3 need to be deleted from s3 instead of the local filesystem.
    if Danbooru.config.use_s3_proxy?(post)
      raise NotImplementedError.new("Replacing S3 hosted images not yet supported.")
    end

    transaction do
      upload = Upload.create!(source: replacement_url, rating: post.rating, tag_string: post.tag_string)
      upload.process_upload
      upload.update(status: "completed", post_id: post.id)

      # queue the deletion *before* updating the post so that we use the old
      # md5/file_ext to delete the old files. if saving the post fails,
      # this is rolled back so the job won't run.
      Post.delay(queue: "default", run_at: Time.now + DELETION_GRACE_PERIOD).delete_files(post.id, post.file_path, post.large_file_path, post.preview_file_path)

      post.md5 = upload.md5
      post.file_ext = upload.file_ext
      post.image_width = upload.image_width
      post.image_height = upload.image_height
      post.file_size = upload.file_size
      post.source = upload.source
      post.tag_string = upload.tag_string

      post.comments.create!({creator: User.system, body: post.presenter.comment_replacement_message(creator), do_not_bump_post: true}, without_protection: true)
      ModAction.log(post.presenter.modaction_replacement_message)

      post.save!
    end

    # point of no return: these things can't be rolled back, so we do them
    # only after the transaction successfully commits.
    post.distribute_files
    post.update_iqdb_async
  end
end
