#!/usr/bin/env ruby

require_relative "../../config/environment"

def create_symlinks(dir)
  FileUtils.mkdir_p(dir)

  (0..255).each do |i|
    subdir = "#{dir}/#{"%.2x" % i}"

    if File.exist?(subdir)
      puts "skipping #{subdir}"
    else
      puts "ln -sf . #{subdir}"
      FileUtils.ln_sf(".", subdir)
    end
  end
end

root = Rails.root.join("public/data")

create_symlinks(root)
create_symlinks("#{root}/sample")
create_symlinks("#{root}/preview")
create_symlinks("#{root}/crop")

FileUtils.ln_sf(".", "#{root}/original") unless File.exist?("#{root}/original")
