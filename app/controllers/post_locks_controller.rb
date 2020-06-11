class PostLocksController < ApplicationController
  respond_to :html, :xml, :json, :js

  def new
    last_lock = PostLock.post_last_lock(params.dig(:post_lock, :post_id))
    if PostLock.update_existing_lock?(last_lock, CurrentUser.user)
      @post_lock = last_lock
    else
      @post_lock = authorize PostLock.new(permitted_attributes(PostLock))
      @post_lock.bit_flags = last_lock.bit_flags if last_lock
      @post_lock.min_level = last_lock.min_level if last_lock
    end

    respond_with(@post_lock)
  end

  def search
  end

  def index
    @post_locks = authorize PostLock.visible(CurrentUser.user).paginated_search(params, count_pages: true)
    @post_locks = @post_locks.includes(:creator, :post) if request.format.html?

    respond_with(@post_locks)
  end

  def show
    authorize PostLock
    redirect_to post_locks_path(search: { id: params[:id] })
  end

  def create_or_update
    if params.dig(:post_lock, :post_id).nil?
      raise ArgumentError, "post ID missing"
    end

    last_lock = PostLock.post_last_lock(params[:post_lock][:post_id])
    if PostLock.update_existing_lock?(last_lock, CurrentUser.user)
      @post_lock = authorize last_lock.update_locks(permitted_attributes(PostLock))
    elsif last_lock.present?
      @post_lock = authorize last_lock.carryover_locks(permitted_attributes(PostLock))
    else
      @post_lock = authorize PostLock.new(creator: CurrentUser.user, **permitted_attributes(PostLock))
      @post_lock.save
    end

    @has_error = !@post_lock.valid?
    flash[:error] = @post_lock.errors.full_messages.join("; ") if @has_error
    respond_with(@post_lock)
  end
end
