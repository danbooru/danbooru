# frozen_string_literal: true

class DiscordSlashCommand
  class TimeCommand < DiscordSlashCommand
    self.name = "time"
    self.description = "Show the current time around the world"
    self.options = [{
      name: "name",
      description: "The name of the country to show",
      required: false,
      type: ApplicationCommandOptionType::String
    }]

    def call
      name = params[:name]

      if name.present?
        msg = times_for_country(name)
        msg = "Timezone not found: #{name}" if msg.blank?
      else
        msg = <<~EOS
          `US (west): #{time("US/Pacific")}`
          `US (east): #{time("US/Eastern")}`
          `Europe:    #{time("Europe/Berlin")}`
          `Japan:     #{time("Asia/Tokyo")}`
          `Australia: #{time("Australia/Sydney")}`
        EOS
      end

      respond_with(msg)
    end

    def times_for_country(country_name)
      country = TZInfo::Country.all.find do |country|
        country.name.downcase == country_name.downcase
      end

      return nil if country.nil?

      zones = country.zones.group_by(&:abbr).transform_values(&:first).values
      zones.map do |zone|
        "`#{zone.friendly_identifier}: #{time(zone.identifier)}`"
      end.join("\n")
    end

    # format: Thu, Nov 02 2017  6:11 PM CDT
    def time(zone, format: "%a, %b %d %Y %l:%M %p %Z")
      Time.use_zone(zone) { Time.current.strftime(format) }
    end
  end
end
