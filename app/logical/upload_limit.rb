# Calculates a user's upload limit:
#
# * Each status:pending post takes up one upload slot.
# * Each status:appealed post takes up three upload slots.
# * If any of your uploads are manually deleted in under three days (status:deleted age:<3d), they take up five upload slots.
# * Slots are freed when uploads are approved or deleted.
# * You start out with 15 upload slots and can have between 5 and 40 upload slots.
# * You gain and lose slots based on approvals and deletions:
# ** You lose a slot for every 3 deletions.
# ** You gain a slot for every N approved uploads, where N depends on how many slots you already have:
# *** If you have 15 slots or less, then you gain a slot for every 10 approved uploads.
# *** If you have more than 15 slots, then you need 10 approvals, plus 2 more per upload slot over 15.
#
# Internally, upload limits are based on a point system, where you start with
# 1000 points and level up to 10,000 points. Each approval is worth 10 points
# and each deletion costs 1/3 of the points to the next level. Points are mapped
# to levels such that each level costs 20 more points (2 approvals) than the
# last. Levels are mapped to upload slots such that levels range from 0 - 35,
# and upload slots range from 5 - 40.
#
# @see https://danbooru.donmai.us/wiki_pages/about:upload_limits
class UploadLimit
  extend Memoist

  INITIAL_POINTS = 1000
  MAXIMUM_POINTS = 10_000
  APPEAL_COST = 3
  DELETION_COST = 5

  attr_reader :user

  # Create an upload limit object for a user.
  # @param user [User]
  def initialize(user)
    @user = user
  end

  # @return [Boolean] true if the user can't upload because they're out of upload slots.
  def limited?
    !user.can_upload_free? && used_upload_slots >= upload_slots
  end

  # @return [Boolean] true if the user is at max level.
  def maxed?
    user.upload_points >= MAXIMUM_POINTS
  end

  # @return [Integer] The number of upload slots in use. Pending posts take 1
  #   slot, appeals take 3, and early deletions take 5.
  def used_upload_slots
    pending_count = user.posts.pending.count
    appealed_count = user.post_appeals.pending.count
    early_deleted_count = user.posts.deleted.where("created_at >= ?", Danbooru.config.moderation_period.ago).count

    pending_count + (early_deleted_count * DELETION_COST) + (appealed_count * APPEAL_COST)
  end

  # @return [Integer] The number of unused upload slots, that is, the number of
  #   posts the user can upload.
  def free_upload_slots
    upload_slots - used_upload_slots
  end

  # @return [Integer] The user's total number of upload slots. Ranges from 5 to 40.
  def upload_slots
    upload_level + 5
  end

  # @return [Integer] The user's current upload level. Ranges from 0 to 35.
  def upload_level
    UploadLimit.points_to_level(user.upload_points)
  end

  # @return [Integer] The number of approvals received so far on the current level.
  def approvals_on_current_level
    (user.upload_points - UploadLimit.level_to_points(upload_level)) / 10
  end

  # @return [Integer] The number of approvals needed to reach the next level.
  def approvals_for_next_level
    UploadLimit.points_for_next_level(upload_level) / 10
  end

  # Update the uploader's upload points when a post is approved or deleted.
  # This must be called *after* the post is approved or deleted.
  #
  # @param is_pending [Boolean] true if the post is pending, false if the post is
  #   active, flagged, appealed, or deleted.
  # @param is_approval [Boolean] true if the post is being approved or
  #   undeleted, false if the post is being deleted.
  def update_limit!(is_pending, is_approval)
    return if user.can_upload_free?

    user.with_lock do
      # If we're approving or deleting a pending post, we can simply increment
      # or decrement the upload points.
      if is_pending
        user.upload_points += UploadLimit.upload_value(user.upload_points, !is_approval)
        user.upload_points = user.upload_points.clamp(0, MAXIMUM_POINTS)
        user.save!

      # If we're undeleting a deleted or appealed post, or deleting a flagged
      # or active post, then we have to replay the user's entire upload
      # history to recalculate their upload points.
      else
        user.update!(upload_points: UploadLimit.points_for_user(user))
      end
    end
  end

  # Recalculate the user's upload points based on replaying their entire upload history.
  # @param user [User] the user
  # @return [Integer] the user's upload points
  def self.points_for_user(user)
    points = INITIAL_POINTS

    uploads = user.posts.where(is_pending: false).order(id: :asc).pluck(:is_deleted)
    uploads.each do |is_deleted|
      points += upload_value(points, is_deleted)
      points = points.clamp(0, MAXIMUM_POINTS)

      # warn "slots: %2d, points: %3d, value: %2d" % [UploadLimit.points_to_level(points) + 5, points, UploadLimit.upload_value(level, is_deleted)]
    end

    points
  end

  # Calculate the value of a approval or deletion. Approvals are worth a fixed
  # 10 points. Deletions cost 1/3 of the points needed for the next level.
  #
  # @param current_points [Integer] the user's current number of upload points
  # @param is_deleted [Boolean] whether the post was deleted or approved
  # @return [Integer] the number of points this upload is worth
  def self.upload_value(current_points, is_deleted)
    if is_deleted
      level = points_to_level(current_points)
      -1 * (points_for_next_level(level) / 3.0).round.to_i
    else
      10
    end
  end

  # Calculate the number of upload points needed to reach the next upload level.
  # This is the number of approvals needed, times 10.
  # @param level [Integer] the current upload level
  # @return [Integer] The number of points needed to reach the next upload level
  def self.points_for_next_level(level)
    100 + 20 * [level - 10, 0].max
  end

  # Calculate the level that corresponds to a given number of upload points.
  # @param [Integer] the upload points (0 - 10,000)
  # @return [Integer] the upload level (0 - 35)
  def self.points_to_level(points)
    level = 0

    loop do
      points -= points_for_next_level(level)
      break if points < 0
      level += 1
    end

    level
  end

  # Calculate the base upload points that correspond to a given upload level.
  # @param [Integer] the upload level (0 - 35)
  # @return [Integer] the upload points (0 - 10,000)
  def self.level_to_points(level)
    (1..level).map do |n|
      points_for_next_level(n - 1)
    end.sum
  end
end
