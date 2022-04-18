#!/usr/bin/env ruby

require_relative "base"

with_confirmation do
  FavoriteGroup.where(name: %w[any none]).find_each do |favgroup|
    old_name = favgroup.name
    favgroup.update!(name: "favgroup_#{favgroup.id}")

    Dmail.create_automated(to: favgroup.creator, title: "Your favorite group has been renamed", body: <<~EOS)
      Your favgroup ##{favgroup.id} has been renamed from "#{old_name}" to "#{favgroup.name}". "#{old_name}" is no longer an allowed favgroup name.
      You can go "here":/favorite_groups/#{favgroup.id}/edit to change your favgroup's name to something else.
    EOS
  end
end
