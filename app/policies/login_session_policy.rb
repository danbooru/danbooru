# frozen_string_literal: true

class LoginSessionPolicy < ApplicationPolicy
  # Login IDs and session IDs are secrets stored in the session cookie, so they can only be searched by exact match.
  def searchable_attributes
    [:id, :created_at, :updated_at, :user, :status, :last_seen_at, { login_id: :exact, session_id: :exact }]
  end
end
