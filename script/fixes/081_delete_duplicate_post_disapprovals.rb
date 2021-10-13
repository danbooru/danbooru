#!/usr/bin/env ruby

require_relative "../../config/environment"

PostDisapproval.transaction do
  PostDisapproval.destroy_duplicates!(:user_id, :post_id)
end
