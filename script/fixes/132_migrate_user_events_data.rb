#!/usr/bin/env ruby

require_relative "base"

fix = ENV.fetch("FIX", "false").truthy?
cond = ENV.fetch("COND", "user_events.ip_addr IS NULL")

UserEvent.joins(:user_session).where(cond).find_each do |event|
  event.ip_addr = event.user_session.ip_addr
  event.session_id = event.user_session.session_id
  event.user_agent = event.user_session.user_agent

  puts ({ id: event.id, ip_addr: event.ip_addr.to_s, session_id: event.session_id, user_agent: event.user_agent }).to_json
  event.save!(touch: false) if fix
end
