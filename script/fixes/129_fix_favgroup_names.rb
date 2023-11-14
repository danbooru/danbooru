#!/usr/bin/env ruby

require_relative "base"

with_confirmation do
  fix = ENV.fetch("FIX", "false").truthy?

  users = User.where.associated(:favorite_groups).distinct
  users.find_each do |user|
    changed_favgroups = []

    user.favorite_groups.each do |favgroup|
      if favgroup.name.match?(/[^[:graph:]]/)
        favgroup.name.gsub!(/[^[:graph:]]/, "_")
      end

      if favgroup.name.include?("*")
        favgroup.name.tr!("*", "?")
      end

      if favgroup.name.include?("__")
        favgroup.name.gsub!(/_+/, "_")
      end

      if favgroup.name.starts_with?("_")
        favgroup.name.delete_prefix!("_")
      end

      if favgroup.name.ends_with?("_")
        favgroup.name.delete_suffix!("_")
      end

      if favgroup.name.match?(/\A[0-9]+\z/)
        favgroup.name = "favgroup_#{favgroup.name}"
      end

      if favgroup.name.blank? || user.favorite_groups.without(favgroup).exists?(name: favgroup.name)
        favgroup.name = "favgroup_#{favgroup.id}"
      end

      if favgroup.changed?
        changed_favgroups << favgroup
        puts ({ id: favgroup.id, creator: favgroup.creator.name, changes: favgroup.changes }).to_json
        favgroup.save! if fix
      end
    end

    if fix && changed_favgroups.present?
      Dmail.create_automated(to: user, title: "Your favorite groups have been renamed", disable_email_notifications: true, body: <<~EOS)
        The following #{"favgroup".pluralize(changed_favgroups.size)} #{changed_favgroups.one? ? "has" : "have"} been renamed:

        #{changed_favgroups.map { |favgroup| "* favgroup ##{favgroup.id}: \"#{favgroup.name_was}\" -> \"#{favgroup.name}\"" }.join("\n")}

        Your #{"favgroup".pluralize(changed_favgroups.size)} had to be renamed because #{changed_favgroups.one? ? "it" : "they"} didn't follow one of our new naming rules:

        * Names can't consist of numbers only.
        * Names can't start or end with an underscore (_).
        * Names can't contain multiple underscores in a row (__).
        * Names can't contain commas or asterisks (*).
        * Names can't be blank.

        You can change the name to something else by going to your "Favgroups":[/favorite_groups] page and clicking "Edit" to change the name.
      EOS
    end
  end
end
