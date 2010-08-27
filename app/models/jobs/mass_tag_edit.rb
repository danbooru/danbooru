module Jobs
  class MassTagEdit < Struct.new(:start_tags, :result_tags, :updater_id, :updater_ip_addr)
    def perform
      Tag.mass_edit(start_tags, result_tags, updater_id, updater_ip_addr)
    end
  end
end
