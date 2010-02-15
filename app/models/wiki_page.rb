class WikiPage < ActiveRecord::Base
  attr_accessor :updater_id, :updater_ip_addr
end
