module Moderator
  module Dashboard
    module Queries
      class Tag < ::Struct.new(:user, :count)
        def self.all(min_date, max_level)
          return [] unless PostVersion.enabled?

          records = PostVersion.where("updated_at > ?", min_date).group(:updater).count.map do |user, count|
            new(user, count)
          end

          records.select { |rec| rec.user.level <= max_level }.sort_by(&:count).reverse.take(10)
        end
      end
    end
  end
end
